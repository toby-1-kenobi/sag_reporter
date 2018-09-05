class AndroidSyncController < ApplicationController

  include JwtConcern
  include ParamsHelper

  skip_before_action :verify_authenticity_token
  #before_action :authenticate_external

  def send_request
    safe_params = [
        :last_sync
    ]
    send_request_params = params.require(:external_device).permit(safe_params)

    tables = [
        [User, %w(name user_type)],
        [GeoState, %w(name zone_id)],
        [LanguageProgress, %w(progress_marker_id state_language_id)],
        [Language, %w(name)],
        [Person, %w(name geo_state_id)],
        [Topic, %w(name colour)],
        [ProgressMarker, %w(name topic_id)],
        [Zone, %w(name)],
        [ImpactReport, %w(translation_impact)],
        [UploadedFile, %w(report_id)],
        [MtResource, %w(user_id name language_id medium geo_state_id url)],
        [Organisation, %w(name abbreviation church)],
        [ProgressUpdate, %w(user_id language_progress_id progress month year)],
        [LanguageProgress, %w(progress_marker_id state_language_id)],
        [StateLanguage, %w(geo_state_id language_id project)],
        [ChurchTeam, %w(name organisation_id village)],
        [ChurchMinistry, %w(church_team_id ministry_id language_id status)],
        [Ministry, %w(name description topic_id)],
        [Deliverable, %w(name description ministry_id for_facilitator)],
        [MinistryOutput, %w(deliverable_id month value actual church_ministry_id creator_id comment)],
        [ProductCategory, %w(name)],
        [Project, %w(name)],
        [FacilitatorFeedback, %w(church_ministry_id month feedback team_member_id response)],
        [Report, %w(reporter_id content geo_state_id report_date impact_report_id status client version significant project_id church_ministry_id)]
    ]
    exclude_attributes = {
        User: %w(password_digest remember_digest otp_secret_key confirm_token reset_password reset_password_token)
    }
    join_tables = {
        User: %w(geo_states spoken_languages languages ministries),
        Report: %w(languages observers),
        ImpactReport: %w(progress_markers),
        ChurchTeam: %w(users),
        Project: %w(languages project_users),
        MtResource: %w(product_categories)
    }
    def additional_tables(entry)
      case entry
        when ProgressMarker
          {description: entry.description_for(@external_user)}
        when ProgressUpdate
          {month: "#{entry.year}-#{'%02i' % entry.month}"}
        when StateLanguage
          {is_primary: entry.primary}
        else
          {}
      end
    end
    @final_file = Tempfile.new
    render json: {data: "#{@final_file.path}.txt"}, status: :ok
    Thread.new do
      begin
        File.open(@final_file, "w") do |file|
          @sync_time = 5.seconds.ago
          file.write "{\"last_sync\":#{@sync_time.to_i}"
          raise "No last sync variable" unless send_request_params["last_sync"]
          last_sync = Time.at send_request_params["last_sync"]
          @needed = {:updated_at => last_sync .. @sync_time}
          tables.each do |table, attributes|
            table_name = table.name.to_sym
            file.write(",")
            file.write "\"#{table_name}\":["
            table.where(@needed).includes(join_tables[table_name]).each_with_index do |entry, index|
              entry_data = Hash.new
              (attributes + ["id"]).each do |attribute|
                entry_data.merge!({attribute => entry.send(attribute)})
              end
              join_tables[table_name]&.each do |join_table|
                entry_data.merge!({join_table => entry.send(join_table.singularize.foreign_key.pluralize)})
              end
              begin
                entry_data.merge! additional_tables(entry)
              rescue
                logger.error "Error in adding additional tables for #{entry.class}: #{entry.attributes}"
              end
              file.write(",") if index != 0
              file.write entry_data.to_json
            end
            file.write "]"
            ActiveRecord::Base.connection.query_cache.clear
          end
          file.write "}"
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
        raise "Creating of the file took to long" if Time.now > deadline
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
        :uploaded_files => [],
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
      safe_params = [
          :is_only_test,
          :person => [
              :old_id,
              :name,
              :user_id,
              :geo_state_id

          ],
          :uploaded_file => [
              :old_id,
              :data
          ],
          :report => [
              :id,
              :old_id,
              :geo_state_id,
              {:language_ids => []},
              :language_ids,
              :report_date,
              :translation_impact,
              :significant,
              {:picture_ids => []},
              :picture_ids,
              :content,
              :reporter_id,
              :impact_report,
              {:progress_marker_ids => []},
              :progress_marker_ids,
              {:observer_ids => []},
              :observer_ids,
              :client,
              :version,
              :impact_report => [
                  {:impact_report => [
                      :id,
                      :old_id,
                      :shareable,
                      :translation_impact
                  ]}
              ]
          ],
          :church_congregation => [
              :id,
              :old_id,
              {:user_ids => []},
              :user_ids,
              :village
          ],
          :church_ministry => [
              :id,
              :old_id,
              :church_congregation_id,
              :ministry_id
          ],
          :ministry_output => [
              :id,
              :old_id,
              :church_ministry_id,
              :ministry_marker_id,
              :creator,
              :value,
              :actual
          ]
      ]
      receive_request_params = params.deep_transform_keys!(&:underscore).require(:external_device).permit(safe_params)

      @is_only_test = receive_request_params["is_only_test"]
      @errors = []
      @id_changes = {}

      [Person, ImpactReport, Report, UploadedFile].each do |table|
        receive_request_params[table.name.underscore]&.each do |entry|
          new_entry = build table, entry.to_h
          if @is_only_test
            raise new_entry.errors.messages.to_s unless !new_entry || new_entry.valid?
          else
            raise new_entry.errors.messages.to_s unless !new_entry || new_entry.save
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

  # receive_request methods:

  def build(table, hash)
    old_id = nil
    begin
      if table == Report && hash["reporter_id"] != @external_user && !@external_user.admin
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
      hash.each do |k, v|
        if v.is_a? Array
          v.map! do |element|
            # A hash inside an array means always, that the the ID has to be mapped according to the newly created ID
            # An example would be {..., "observers" => [20, {"old_id" => "Person;100010"}]}
            if element.is_a? Hash
              table, old_id = element.values.first.split(";")
              @id_changes[table][old_id.to_i]
            else
              element
            end
          end
        elsif v.is_a? Hash
          intern_table = v.keys.first.camelcase.constantize rescue nil
          if intern_table && v.values.first.is_a?(Hash)
            hash[k] = build intern_table, v.values.first
          end
        elsif v == nil
          hash[k] = [] if k[-4..-1] == "_ids"
        end
      end
      logger.debug "#{table}: #{hash}"
      @id_changes[table.name] ||= {}
      if (id = hash["id"])
        entry = @is_only_test? table.find(id) : table.update(id, hash)
        @id_changes[table.name].merge!({id => entry})
        entry
      elsif (old_id = hash.delete "old_id")
        new_entry = table.new hash
        @id_changes[table.name].merge!({old_id => new_entry})
        new_entry
      else
        raise "Entry needs either an ID value or an 'old ID' value"
      end
    rescue => e
      @errors << {"#{table.name}:#{old_id}" => e.message}
      return nil
    ensure
      if @tempfile
        @tempfile.close
        @tempfile.unlink
      end
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
