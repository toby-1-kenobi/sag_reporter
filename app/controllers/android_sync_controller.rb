class AndroidSyncController < ApplicationController

  include JwtConcern
  include ParamsHelper

  skip_before_action :verify_authenticity_token
  before_action :authenticate_external

  def send_request
    # The following tables have to be in the order, that the table-restrictions only depend on the previous ones
    tables = {
        User => %w(name),
        StateLanguage => %w(geo_state_id language_id project),
        GeoState => %w(name),
        Language => %w(name colour),
        Person => %w(name geo_state_id),
        Topic => %w(name colour),
        ProgressMarker => %w(name topic_id number),
        Report => %w(reporter_id content geo_state_id report_date impact_report_id status client version significant project_id),
        ImpactReport => %w(translation_impact),
        UploadedFile => %w(report_id),
        Organisation => %w(name abbreviation church),
        LanguageProgress => %w(progress_marker_id state_language_id),
        ProgressUpdate => %w(user_id language_progress_id),
        ChurchTeam => %w(organisation_id leader state_language_id),
        ChurchMinistry => %w(church_team_id ministry_id status facilitator_id),
        Ministry => %w(topic_id name_id code),
        Deliverable => %w(ministry_id calculation_method reporter short_form_id plan_form_id result_form_id number),
        TranslationCode => %w(),
        Translation => %w(language_id content translation_code_id),
        MinistryOutput => %w(deliverable_id month value actual church_ministry_id creator_id comment),
        ProductCategory => nil,
        Project => %w(name),
        ProjectStream => %w(project_id ministry_id supervisor_id),
        ProjectSupervisor => %w(project_id user_id role),
        ProjectProgress => nil,
        FinishLineMarker => nil,
        FinishLineProgress => nil,
        Edit => nil,
        Tool => nil,
        AggregateMinistryOutput => %w(deliverable_id month value actual creator_id comment state_language_id),
        QuarterlyTarget => %w(state_language_id deliverable_id quarter value),
        LanguageStream => %w(state_language_id ministry_id facilitator_id project_id),
        SupervisorFeedback => %w(ministry_id supervisor_id facilitator_id month plan_feedback plan_response result_feedback facilitator_progress project_progress state_language_id),
        FacilitatorFeedback => %w(church_ministry_id month plan_feedback plan_team_member_id plan_response facilitator_plan result_feedback result_response result_team_member_id progress)
    }
    join_tables = {
        User: %w(geo_states),
        Report: %w(languages observers),
        ImpactReport: %w(progress_markers),
        ChurchTeam: %w(users),
        Project: %w(state_languages),
        Tool: %w(product_categories)
    }
    additional_join_tables = {
        Report: %w(ministries),
        Deliverable: %w(ministry),
        User: %w(external_devices)
    }
    def additional_tables(entry)
      case entry
      when ProgressUpdate
        {month: "#{entry.year}-#{sprintf('%02d', entry.month)}"}
      when StateLanguage
        {is_primary: entry.primary}
      when User
        additional_entry = entry.id == @external_user.id ? entry : User.new
        additional_entry.attributes.slice(*%w(phone mother_tongue_id interface_language_id email trusted national admin national_curator role_description))
            .merge(external_device_registered: !entry.external_devices.empty?)
      when Edit
        {created_at: entry.created_at.to_i}
      else
        {}
      end
    end
    @all_restricted_ids = Hash.new
    def restrict(table)
      table_implementation = table.new
      unless @project_ids && @state_language_ids && @language_ids && @geo_state_ids
        @project_ids = ProjectStream.where(supervisor: @external_user).map(&:project_id) +
            ProjectSupervisor.where(user: @external_user).map(&:project_id)
        user_geo_state_ids = @external_user.national? ? GeoState.ids : @external_user.geo_state_ids
        @state_language_ids = Project.includes(:state_languages).where(id: @project_ids).map(&:state_language_ids).flatten +
            LanguageStream.where(facilitator: @external_user).map(&:state_language_id) +
            ChurchTeamMembership.includes(:church_team).where(user: @external_user).map(&:church_team).map(&:state_language_id) +
            StateLanguage.where(geo_state_id: user_geo_state_ids).ids
        state_languages = StateLanguage.where(id: @state_language_ids)
        @language_ids = state_languages.map &:language_id
        @geo_state_ids = state_languages.map(&:geo_state_id)
      end
      restricted_ids =
        case table_implementation
        when User
          if @project_ids.empty?
            [@external_user.id]
          elsif @external_user.trusted?
            table.ids
          else
            LanguageStream.where(project_id: @project_ids).map(&:facilitator_id) + [@external_user.id]
          end
        when Language
          table.where(id: @language_ids).ids
        when GeoState
          table.where(id: @geo_state_ids).ids
        when Project
          table.where(id: @project_ids).ids
        when StateLanguage
          table.where(id: @state_language_ids).ids
        when MtResource
          table.where(language_id: @language_ids, geo_state_id: @geo_state_ids).ids
        when Report
          table.where("report_date >= ?", Date.new(2018, 1, 1))
              .where(geo_state_id: @geo_state_ids).language(@language_ids).ids
        when UploadedFile
          table.where(report_id: @all_restricted_ids[Report]).ids
        when ChurchTeam
          table.where(state_language_id: @state_language_ids).ids
        when ChurchMinistry
          table.where(church_team_id: @all_restricted_ids[ChurchTeam]).ids
        when QuarterlyTarget
          table.where(state_language_id: @state_language_ids).ids
        when AggregateMinistryOutput
          table.where(state_language_id: @state_language_ids).ids
        when MinistryOutput
          table.where(church_ministry_id: @all_restricted_ids[ChurchMinistry]).ids
        when FacilitatorFeedback
          table.where(church_ministry_id: @all_restricted_ids[ChurchMinistry]).ids
        when ProjectStream
          table.where(project_id: @all_restricted_ids[Project]).ids
        when ProjectSupervisor
          table.where(project_id: @all_restricted_ids[Project]).ids
        when LanguageStream
          table.where(state_language_id: @state_language_ids).ids
        when ImpactReport
          table.joins(:report).where(reports:{id: @all_restricted_ids[Report]}).ids
        when Person
          table.joins(:reports).where(reports:{id: @all_restricted_ids[Report]}).ids
        when FinishLineProgress
          table.where(language_id: @language_ids).ids
        when Edit
          table.pending.where(user: @external_user)
        else
          table.ids
      end
      unless @external_user.national
        restricted_ids = case table_implementation
          when StateLanguage
            table.where(id: restricted_ids, geo_state_id: @geo_state_ids).ids
          when Person
            table.where(id: restricted_ids, geo_state_id: @geo_state_ids).ids
          when MtResource
            table.where(id: restricted_ids, geo_state_id: @geo_state_ids).ids
          when Report
            table.where(id: restricted_ids, geo_state_id: @geo_state_ids).ids
            
          when ChurchTeam
            table.joins(:state_language).where(id: restricted_ids, state_languages: {id: @all_restricted_ids[StateLanguage]}).ids
          when LanguageProgress
            table.joins(:state_language).where(id: restricted_ids, state_languages: {id: @all_restricted_ids[StateLanguage]}).ids
          when Language
            table.joins(:state_languages).where(id: restricted_ids, state_languages: {id: @all_restricted_ids[StateLanguage]}).ids
          when ProgressUpdate
            table.where(id: restricted_ids, language_progress_id: @all_restricted_ids[LanguageProgress]).ids
          when MinistryOutput
            table.where(id: restricted_ids, church_ministry_id: @all_restricted_ids[ChurchMinistry]).ids
          when FacilitatorFeedback
            table.where(id: restricted_ids, church_ministry_id: @all_restricted_ids[ChurchMinistry]).ids
          when Project
            table.joins(:state_languages).where(id: restricted_ids, state_languages: {id: @all_restricted_ids[StateLanguage]}).ids
          else
            restricted_ids
        end
      end
      unless @external_user.trusted
        restricted_ids = case table_implementation
          when Organisation
            table.where(id: restricted_ids, church: true).ids
          when Report
            table.where(id: restricted_ids, reporter_id: @external_user.id).ids
          else
            restricted_ids
        end
      end
      @all_restricted_ids[table] = restricted_ids
    end

    def convert_value(value)
      case value
      when Date
        value.strftime("'%Y-%m-%d'")
      when String
        "'#{value.gsub("'","''")}'"
      when TrueClass
        1
      when FalseClass
        0
      when NilClass
        "null"
      else
        value
      end
    end

    safe_params = [
        :version,
        :last_sync
    ] + tables.map{|table, _| {table.name => []} }
    send_request_params = params.require(:external_device).permit(safe_params)
    
    @version = send_request_params["version"] || ""
    @final_file = Tempfile.new
    render json: {data: "#{@final_file.path}.txt"}, status: :ok
    tables[Report] << "church_team_id" if @version > "1.4"
    join_tables[:Report] << "ministries" if @version > "1.4"
    tables[ProjectProgress] = %w(project_stream_id month progress comment approved) if @version >= "1.4.1"
    tables[FinishLineMarker] = %w(name description number) if @version >= "1.4.2"
    tables[FinishLineProgress] = %w(language_id finish_line_marker_id status year) if @version >= "1.4.2"
    tables[Ministry] << "short_form_id" if @version >= "1.4.2:85"
    tables[Edit] = %w(model_klass_name record_id attribute_name old_value new_value user_id status curation_date second_curation_date record_errors curated_by_id relationship creator_comment curator_comment) if @version >= "1.4.2:87"
    tables[ProductCategory] = %w(name_id) if @version >= "1.4.2:90"
    tables[Tool] = %w(language_id url description creator_id status) if @version >= "1.4.2:90"
    tables[Tool] << "finish_line_marker_id" if @version >= "1.4.2:92"
    tables[ChurchTeam] << "status" if @version >= "1.4.2:96"
    tables[ProgressMarker] << "status" if @version >= "1.4.4:101"
    tables[ProgressMarker] << "shareable" if @version >= "1.4.4:101"
    formatted_evaluation_info = ""
    formatted_evaluation_info = ", ministry_benchmark_criteria = 'COUNT(CASE " +
        "WHEN deliverable_id = 5 AND value > 0 THEN 1 " +
        "WHEN deliverable_id = 6 AND value > 5 THEN 1 " +
        "WHEN deliverable_id = 8 AND value > 0 THEN 1 " +
        "WHEN deliverable_id = 9 AND value > 5 THEN 1 " +
        "WHEN deliverable_id = 10 AND value > 0 THEN 1 " +
        "WHEN deliverable_id = 11 AND value > 5 THEN 1 " +
        "WHEN deliverable_id = 14 AND value > 2 THEN 1 " +
        "WHEN deliverable_id = 15 AND value > 0 THEN 1 " +
        "WHEN deliverable_id = 1 AND value > 2 THEN 1 " +
        "END) AS not_red, " +
        "COUNT(CASE " +
        "WHEN deliverable_id = 5 AND value > 1 THEN 1 " +
        "WHEN deliverable_id = 6 AND value > 10 THEN 1 " +
        "WHEN deliverable_id = 8 AND value > 1 THEN 1 " +
        "WHEN deliverable_id = 9 AND value > 10 THEN 1 " +
        "WHEN deliverable_id = 10 AND value > 1 THEN 1 " +
        "WHEN deliverable_id = 11 AND value > 10 THEN 1 " +
        "WHEN deliverable_id = 14 AND value > 4 THEN 1 " +
        "WHEN deliverable_id = 15 AND value > 1 THEN 1 " +
        "WHEN deliverable_id = 1 AND value > 9 THEN 1 " +
        "END) AS green FROM ministry_Output " +
        "WHERE deliverable_id IN (5, 6, 8, 9, 10, 11, 14, 15, 1) '" if @version >= "1.4.2:85"
    Thread.new do
      begin
        File.open(@final_file, "w") do |file|
          last_sync = Time.at send_request_params["last_sync"]
          this_sync = 5.seconds.ago
          file.write "UPDATE app SET last_sync = #{this_sync.to_i}#{formatted_evaluation_info};"
          raise "No last sync variable" unless send_request_params["last_sync"]
          deleted_entries = Hash.new
          tables.each do |table, attributes|
            next unless attributes

            join_table_data = Hash.new
            columns = Set.new ["id"] + attributes
            values = Array.new

            table_name = table.name.to_sym
            offline_ids = send_request_params[table.name] || [0]
            restricted_ids = restrict(table)
            logger.debug "Update #{table.name} at: #{restricted_ids.size}. Those are offline already: #{offline_ids.size}"
            table.where("updated_at BETWEEN ? AND ? AND id IN (?) OR id IN (?)",
                        last_sync, this_sync, restricted_ids & offline_ids, restricted_ids - offline_ids)
                .includes(join_tables[table_name].to_a + additional_join_tables[table_name].to_a).each do |entry|
              entry_data = Hash.new
              begin
                entry_values = entry.attributes.slice(*(["id"] + attributes)).values.map {|e| convert_value e}
                entry_data.merge!(entry.attributes.slice(*(["id"] + attributes)))
                join_tables[table_name]&.each do |join_table|
                  foreign_ids = entry.send(join_table.singularize.foreign_key.pluralize)
                  entry_data.merge!({join_table => foreign_ids})
                  identifier = [table.name.underscore, join_table]
                  join_table_data[identifier] ||= Array.new
                  join_table_data[identifier] += foreign_ids.map{|foreign_id| [entry.id,foreign_id]}
                end
                additions = additional_tables(entry)
                entry_data.merge! additions
                entry_values += additions.map{|k,v| columns << k.to_s; convert_value(v)}
                values << entry_values
              rescue => e
                logger.error "Error in table entries for #{entry.class}: #{entry.attributes}" + e.to_s
                logger.error e.backtrace
              end
            end
            unless (offline_ids - restricted_ids).empty? || offline_ids == [0]
              deleted_entries[table_name] = offline_ids - restricted_ids
            end
            columns << "is_online"
            values.map! {|value| "(#{(value+[1]).join(",")})"}
            file.write "INSERT OR REPLACE INTO #{table.name.underscore}(#{columns.map(&:underscore).join ","})VALUES#{values.join ","};" unless values.empty?
            join_table_data.each do |join_table_names, data|
		    file.write "DELETE FROM #{join_table_names.join "_"} WHERE #{join_table_names.first}_id IN (#{values.map{|e|e.split(',')[0].split('(')[1]}.uniq.join ","});"
              file.write "INSERT INTO #{join_table_names.join "_"}(#{join_table_names.first}_id,#{foreign_key_names(join_table_names.second.singularize)}_id)" +
                               "VALUES#{data.map{|d|"(#{d.first},#{d.second})"}.join ","};" unless data.empty?
            end
            ActiveRecord::Base.connection.query_cache.clear
          end
          unless deleted_entries.empty?
            deleted_entries.each do |table, ids|
              file.write "DELETE FROM #{table.to_s.underscore} WHERE id IN (#{ids.select{|id| id < 1000000}.join ","});"
            end
          end
        end
      rescue => e
        send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
        logger.error send_message
        file_path = @final_file.path
        @final_file.delete
        @final_file = File.new file_path, "w"
        @final_file.write send_message
      ensure
        @final_file.close unless @final_file.closed?
        logger.debug "File writing finished"
        #@final_file.open
        #logger.debug @final_file.read
        #@final_file.close
        File.rename(@final_file, "#{@final_file.path}.txt")
        ActiveRecord::Base.connection.close
      end
    end
  end

  def get_file
    begin
      safe_params = [
          :file_path
      ]
      get_file_params = params.require(:external_device).permit(safe_params)

      file_path = get_file_params["file_path"]
      deadline = Time.now + 1.minute
      until File.exists?(file_path)
        sleep 1
        raise "Creating of the file took too long" if Time.now > deadline
      end
      send_file file_path, status: :ok
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  def get_uploaded_file
    safe_params = [
        uploaded_files: [],
    ]
    get_uploaded_file_params = params.require(:external_device).permit(safe_params)

    @all_data = Tempfile.new
    render json: {data: "#{@all_data.path}.txt"}, status: :ok
    Thread.new do
      begin
        uploaded_file_ids = get_uploaded_file_params["uploaded_files"].map {|key, _| key.to_i}
        pictures_data, errors = Array.new(2) {Tempfile.new}
        UploadedFile.includes(:report).find(uploaded_file_ids).each do |uploaded_file|
          image_data = if uploaded_file&.ref.file.exists?
                         Base64.encode64(uploaded_file.ref.read)
                       else
                         ""
                       end
          if external_user.trusted? || uploaded_file.report.reporter == external_user
            pictures_data.write(", ") unless pictures_data.length == 0
            pictures_data.write({
                                    id: uploaded_file.id,
                                    data: image_data
                                }.to_json)
          else
            errors << {"uploaded_file:#{uploaded_file.id}" => "permission denied"}
          end
        end
        send_message = { UploadedFile: pictures_data }
        send_message.merge!({ errors: errors}) unless errors.size == 0
        save_data_in_file send_message
      rescue => e
        send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
        logger.error send_message
        @all_data.write send_message
      ensure
        [@all_data, pictures_data, errors].each &:close
        File.rename(@all_data, "#{@all_data.path}.txt")
        [pictures_data, errors].each &:delete
      end
    end
  end

  def receive_request
    begin
      # The following tables have to be in the order, that they only contain IDs of the previous ones
      safe_params = [
          :is_only_test,
          organisation: [
                  :id,
                  :old_id,
                  :name,
                  :church
          ],
          church_team: [
              :id,
              :old_id,
              {user_ids: []},
              :user_ids,
              :organisation_id,
              :leader,
              :status,
              :state_language_id
          ],
          church_ministry: [
              :id,
              :old_id,
              :church_team_id,
              :ministry_id,
              :status,
              :facilitator_id
          ],
          facilitator_feedback: [
              :id,
              :old_id,
              :church_ministry_id,
              :month,
              :plan_feedback,
              :plan_team_member_id,
              :plan_response,
              :facilitator_plan,
              :result_feedback,
              :result_response,
              :result_team_member_id,
              :progress
          ],
          supervisor_feedback: [
              :id,
              :old_id,
              :facilitator_id,
              :supervisor_id,
              :state_language_id,
              :ministry_id,
              :month,
              :plan_feedback,
              :plan_response,
              :result_feedback,
              :facilitator_progress,
              :project_progress
          ],
          aggregate_ministry_output: [
              :id,
              :old_id,
              :state_language_id,
              :deliverable_id,
              :month,
              :value,
              :comment,
              :creator_id,
              :actual
          ],
          ministry_output: [
              :id,
              :old_id,
              :church_ministry_id,
              :deliverable_id,
              :month,
              :value,
              :comment,
              :creator_id,
              :actual
          ],
          project_progress: [
              :id,
              :old_id,
              :project_stream_id,
              :month,
              :progress,
              :comment,
              :approved
          ],
          person: [
              :id,
              :old_id,
              :name,
              :user_id,
              :geo_state_id
          ],
          impact_report: [
              :id,
              :old_id,
              {progress_marker_ids: []},
              :progress_marker_ids,
              :translation_impact
          ],
          report: [
              :id,
              :old_id,
              :geo_state_id,
              {language_ids: []},
              :language_ids,
              :report_date,
              :translation_impact,
              :significant,
              :content,
              :reporter_id,
              :impact_report_id,
              {observer_ids: []},
              :observer_ids,
              {ministry_ids: []},
              :ministry_ids,
              :project_id,
              :church_team_id,
              :client,
              :version,
          ],
          uploaded_file: [
              :old_id,
              :data,
              :report_id
          ],
          tool: [
              :id,
              :old_id,
              :language_id,
              :creator_id,
              :url,
              :description,
              :status,
              :finish_line_marker_id,
              {product_category_ids: []},
              :product_category_ids
          ],
          edit: [
              :id,
              :old_id,
              :model_klass_name,
              :record_id,
              :attribute_name,
              :old_value,
              :new_value,
              :user_id,
              :status,
              :curation_date,
              :second_curation_date,
              :record_errors,
              :curated_by_id,
              :relationship,
              :creator_comment,
              :curator_comment,
          ]
      ]
      receive_request_params = params.deep_transform_keys!(&:underscore).require(:external_device).permit(safe_params)

      @is_only_test = receive_request_params["is_only_test"]
      @errors = []
      @id_changes = {}
      
      safe_params.second.keys.each do |key|
        table = key.to_s.camelcase.constantize
        receive_request_params[table.name.underscore]&.each {|entry| build table, entry.to_h}
      end
      @id_changes.each do |table, entries|
        entries.each do |old_id, new_entry|
          begin
            if @is_only_test
              @errors << {"#{table}:#{old_id}" => new_entry.errors.messages.to_s} unless new_entry&.valid?
            else
              @errors << {"#{table}:#{old_id}" => new_entry.errors.messages.to_s} unless new_entry&.save
            end
          rescue => e
            logger.error e
            logger.error e.backtrace
            @errors << {"#{table}:#{old_id}" => e.message}
          end
        end
      end
      # Send back all the ID changes (as only the whole entries were saved, the ID has to be retrieved here)
      if @is_only_test
        send_message = @id_changes.map{|k,v| [k, v.map{|k2,v2| [k2, v2.valid?] }.to_h] }.to_h
      else
        send_message = @id_changes.map{|k,v| [k, v.map{|k2,v2| [k2, v2.id] }.to_h] }.to_h
      end
      send_message.merge!({error: @errors}) unless @errors.empty?
      logger.debug send_message
      render json: send_message, status: :created
    rescue => e
      send_message = {error: e.to_s, where: e.backtrace.to_s}.to_json
      logger.error send_message
      render json: send_message, status: :internal_server_error
    end
  end

  private

  def foreign_key_names(table_name)
    {picture: :uploaded_file,
     reporter: :user,
     creator: :user,
     facilitator: :user,
     team_member: :user,
     supervisor: :user,
     observer: :person}[table_name.to_sym]&.to_s || table_name
  end

  # receive_request methods:

  def build(table, hash)
    old_id = nil
    begin
      if table == Report && hash["reporter_id"] != @external_user.id && !@external_user.admin
        Report.find(hash["id"]).touch if hash["id"]
        raise "User is not allowed to edit report #{hash["id"]}"
      elsif table == UploadedFile
        filename = "external_uploaded_image"
        @tempfile = Tempfile.new filename
        @tempfile.binmode
        @tempfile.write Base64.decode64 hash.delete("data")
        @tempfile.rewind
        content_type = `file --mime -b #{@tempfile.path}`.split(";")[0]
        extension = content_type.match(/gif|jpg|jpeg|png/).to_s
        filename += ".#{extension}" if extension
        hash["ref"] = ActionDispatch::Http::UploadedFile
                            .new({
                                     tempfile: @tempfile,
                                     type: content_type,
                                     filename: filename
                                 })
      end
      # Go through all the entries to check, whether it has an ID from another uploaded entry
      not_connected_table = %w(old_id record_id)
      hash.clone.each do |k, v|
        if k.last(4) == "_ids" && v.is_a?(Array)
          foreign_table = k.remove("_ids")
          foreign_table = foreign_key_names(foreign_table)
          foreign_table = foreign_table.camelcase
          hash[k.remove("_ids").pluralize] = v.map do |element|
            @id_changes.dig(foreign_table, element) || foreign_table.constantize.find(element)
          end
          hash.delete k
        elsif k.last(3) == "_id" && !not_connected_table.include?(k)
          foreign_table = k.remove("_id")
          foreign_table = foreign_key_names(foreign_table)
          foreign_table = foreign_table.camelcase
          hash[k.remove("_id")] = @id_changes.dig(foreign_table, v) || foreign_table.constantize.find(v)
          hash.delete k
        elsif v == nil && k.last(4) == "_ids"
          hash[k] = []
        end
      end
      logger.debug "#{table}: #{hash}"
      @id_changes[table.name] ||= {}
      if (id = hash["id"])
        entry = @is_only_test? table.find(id) : table.update(id, hash)
        @id_changes[table.name].merge!({id => entry})
      elsif (old_id = hash.delete "old_id")
        email = hash.delete("significant")
        new_entry = table.new hash
        if table == Report && email&.empty? == false
          new_entry.significant = true
          send_mail new_entry, email
        end
        @id_changes[table.name].merge!({old_id => new_entry})
      else
        raise "Entry needs either an ID value or an 'old ID' value"
      end
    rescue => e
      logger.error e
      logger.error e.backtrace
      @errors << {"#{table}:#{old_id}" => e.message}
    ensure
      if @tempfile
        @tempfile.close
        @tempfile.unlink
      end
    end
  end

  def send_mail(report, email)
    # make sure TLS gets used for delivering this email
    if SendGridV3.enforce_tls
      recipient = User.find_by_email email
      recipient ||= email
      delivery_success = false
      begin
        UserMailer.user_report(recipient, report).deliver_now
        delivery_success = true
      rescue EOFError,
            IOError,
            TimeoutError,
            Errno::ECONNRESET,
            Errno::ECONNABORTED,
            Errno::EPIPE,
            Errno::ETIMEDOUT,
            Net::SMTPAuthenticationError,
            Net::SMTPServerBusy,
            Net::SMTPSyntaxError,
            Net::SMTPUnknownError,
            OpenSSL::SSL::SSLError => e
        logger.error e
        logger.error e.backtrace
      end
      if delivery_success
        # also send it to the reporter
        UserMailer.user_report(report.reporter, report).deliver_now
      end
    else
      logger.error 'Could not enforce TLS with SendGrid'
    end
  end

  def save_data_in_file(send_message)
    File.open(@all_data, "w") do |final_file|
      final_file.write "{"
      send_message.each_with_index do |pair, index|
        category, file = pair
        file.close
        file.open
        final_file.write ", " unless index == 0
        final_file.write "\"#{category}\": ["
        final_file.write file.read
        final_file.write "]"
        file.close
        file.unlink
      end
      final_file.write "}"
    end
    @all_data.close
  end
  # other helpful methods
  
  def authenticate_external
    render json: { error: "JWT invalid", user: @jwt_user_id }, status: :unauthorized unless external_user
  end

  def external_user
    @external_user ||= begin
      token = request.headers["Authorization"].split.last
      payload = decode_jwt(token)
      @jwt_user_id = payload["sub"]
      user = User.find_by_id @jwt_user_id
      users_device = ExternalDevice.find_by device_id: payload["iss"], user_id: @jwt_user_id
      if user.updated_at.to_i == payload["iat"]
        user if users_device
      else
        users_device.update registered: false if users_device&.registered
        false
      end
    rescue => e
      logger.error e
      logger.error e.backtrace
      nil
    end
  end

end
# for easily getting all attributes:
# Language.new.attributes.except("created_at","updated_at").keys.each{|k|puts "          #{k}: xxx.#{k},"}.nil?
# puts tables.map{|t|  "["+t.name + ", %w(" +t.new&.attributes&.except("created_at", "updated_at", "id")&.keys&.join(" ").to_s + ")],"}

# hm=Person.reflect_on_all_associations(:has_many).map{|r|r.name}
# hm2=hm.map{|h|h.to_s.singularize + "_ids"}
# Person.includes(hm).map{|p| hm2.map{|h|[h,p.send(h)]}.to_h.merge(p.attributes.except("created_at", "updated_at"))}

# Language.reflect_on_all_associations(:has_many).map{|a|[a.name,a.options[:through],a.options[:source]]}
# => [[:geo_states, :state_languages, nil],...]
# Language.includes(a.options[:through]).map {|l|l.send(a.options[:through]).map &a.options[:source] || a.name}

# def r t;t.reflect_on_all_associations(:has_many).map {|a|puts [a.name.to_s.singularize.to_sym, a.options[:through], a.options[:source]].to_s};t.reflect_on_all_associations(:has_and_belongs_to_many).map {|a|puts [a.name.to_s.singularize.to_sym, a.options[:through], a.options[:source]].to_s}.nil?; end
