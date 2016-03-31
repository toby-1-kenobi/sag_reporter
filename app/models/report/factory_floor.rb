module Report::FactoryFloor

  private

  def add_languages(state_language_ids, geo_state_id)
    @instance.languages << Language.joins(:state_languages).where(:state_languages => { geo_state_id: geo_state_id, id: state_language_ids })
  end

  def add_topics(topic_ids)
    @instance.topics << Topic.where(id: topic_ids)
  end

  def add_observers(observers, geo_state_id, reporter)
    observers.values.each do |person_attributes|
      if person_attributes[:id].present?
        person = Person.find person_attributes[:id]
      end
      if !person and person_attributes['name'].present?
        person = Person.find_or_initialize_by person_attributes do |person|
          person.geo_state_id = geo_state_id
          person.record_creator = reporter
        end
      end
      if person and not @instance.observers.include? person
        @instance.observers << person
      end
    end
  end

end