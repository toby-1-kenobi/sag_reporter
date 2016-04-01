class Event::Factory

  attr_reader :instance
  attr_reader :errors

  def add_languages(state_language_ids, geo_state)
    @instance.languages << Language.joins(:state_languages).where(:state_languages => { geo_state: geo_state, id: state_language_ids })
  end

  def add_purposes(purpose_ids)
    @instance.purposes << Purpose.where(id: purpose_ids)
  end

  def add_people(people, geo_state, reporter)
    people.values.each do |person_attributes|
      if person_attributes[:id].present?
        person = Person.find person_attributes[:id]
      end
      if !person and person_attributes['name'].present?
        person = Person.find_or_initialize_by person_attributes do |person|
          person.geo_state_id = geo_state
          person.record_creator = reporter
        end
      end
      if person and not @instance.people.include? person
        @instance.people << person
      end
    end
  end

  def add_reports(reports_params)
    report_factory = Report::Factory.new
    reports_params.values.each do |report_params|
      if report_params[:content].present?
        report_params[:reporter] = @instance.record_creator
        report_params[:geo_state] = @instance.geo_state
        report_params[:sub_district] = @instance.sub_district
        report_params[:report_date] = @instance.event_date
        if report_factory.build_report(report_params)
          @instance.reports << report_factory.instance
        elsif report_factory.error
          @errors << report_factory.error
        end
      end
    end
  end

  def add_action_points(action_points, geo_state, reporter)
    action_points.values.each do |action_point_params|
      if action_point_params['content'].present?
        person = Person.find_or_initialize_by({name: action_point_params['responsible']}) do |person|
          person.geo_state = geo_state
          person.record_creator = reporter
        end
        action_point_params['responsible'] = person
        @instance.action_points.build(action_point_params)
      end
    end
  end

  def build_event(params)
    @errors = Array.new
    # Remove parameters that will be handled separately
    state_language_ids = params.delete 'languages'
    purpose_ids = params.delete 'purposes'
    people = params.delete 'people_attributes'
    reports = params.delete 'reports_attributes'
    action_points = params.delete 'action_points_attributes'
    begin
      @instance = Event.new(params)
      add_languages(state_language_ids, @instance.geo_state) if state_language_ids
      add_purposes(purpose_ids) if purpose_ids
      add_people(people, @instance.geo_state, @instance.record_creator) if people
      add_reports(reports) if reports
      add_action_points(action_points, @instance.geo_state, @instance.record_creator)
    rescue => e
      @errors << e
      return false
    else
      return true
    end
  end

  def create_event(params)
    if build_event(params)
      return @instance.save
    else
      return false
    end
  end

end