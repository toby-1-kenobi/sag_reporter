class PutAllStateBasedThingsInStates < ActiveRecord::Migration
  def up

    # for most of these we're making a good guess about which
    # state it should be in. It's possible we get it wrong for some things.
    # but it's better than not being in any state.

    Report.where(geo_state: nil).each do |report|
      if language = report.languages.take
        report.geo_state = language.geo_states.take
      else
        report.geo_state = report.reporter.geo_states.take
      end
      report.save!
    end
    change_column_null :reports, :geo_state_id, false

    change_column_null :impact_reports, :reporter_id, false
    ImpactReport.where(geo_state: nil).each do |report|
      if language = report.languages.take
        report.geo_state = language.geo_states.take
      else
        report.geo_state = report.reporter.geo_states.take
      end
      report.save!
    end
    change_column_null :impact_reports, :geo_state_id, false

    MtResource.where(geo_state: nil).each do |resource|
      resource.geo_state = resource.language.geo_states.take
      resource.save!
    end
    change_column_null :mt_resources, :geo_state_id, false

    Event.where(geo_state: nil).each do |event|
      if language = event.languages.take
        event.geo_state = language.geo_states.take
      elsif creator = event.record_creator
        event.geo_state = creator.geo_states.take
      else
        # if all else fails put the event in West Bengal
        event.geo_state = GeoState.find_by_name "(northern) West Bengal"
      end
      event.save!
    end
    change_column_null :events, :geo_state_id, false

    Person.where(geo_state: nil).each do |person|
      if person.mother_tongue
        person.geo_state = person.mother_tongue.geo_states.take
      elsif event = person.events.take
        if language = event.languages.take
          person.geo_state = language.geo_states.take
        else
          person.geo_state = event.record_creator.geo_states.take
        end
      elsif creator = person.record_creator
        person.geo_state = creator.geo_states.take
      else
        # if all else fails put the person in West Bengal
        person.geo_state = GeoState.find_by_name "(northern) West Bengal"
      end
      person.save!
    end
    change_column_null :people, :geo_state_id, false

    OutputCount.where(geo_state: nil).each do |count|
      count.geo_state = count.language.geo_states.take
      count.save!
    end
    change_column_null :output_counts, :geo_state_id, false

  end
  
  def down
    change_column_null :output_counts, :geo_state_id, true
    change_column_null :people, :geo_state_id, true
    change_column_null :events, :geo_state_id, true
    change_column_null :events, :user_id, true
    change_column_null :mt_resources, :geo_state_id, true
    change_column_null :impact_reports, :geo_state_id, true
    change_column_null :impact_reports, :reporter_id, true
    change_column_null :reports, :geo_state_id, true
  end
end
