class EventsController < ApplicationController

  include ParamsHelper

  before_action :require_login

  autocomplete :person, :name
  
  def new
  	@event = Event.new
    @event.people.build
  	@project_languages = StateLanguage.in_project.joins(:language).where(geo_state: current_user.geo_states).order('LOWER(languages.name)')
  	@all_purposes = Purpose.all
  end

  def create
    full_params = event_params.merge({record_creator: current_user})
    event_factory = Event::Factory.new
    if event_factory.create_event(full_params)
      redirect_to event_factory.instance
    else
      @event = event_factory.instance
      @event ||= Event.new
      @event.people.build
      flash.now['error'] = event_factory.errors.any? ? event_factory.errors.first.message : 'Unable to submit event report!'
      @project_languages = StateLanguage.in_project.joins(:language).where(geo_state: current_user.geo_states).order('LOWER(languages.name)')
      @all_purposes = Purpose.all
      render 'new'
    end
  end

  def show
  	@event = Event.find(params[:id])
  end

  private

    def event_params
      # make hash options into arrays
      param_reduce(params['event'], ['purposes', 'languages'])
      params.require('event').permit(
      	:event_label,
        :geo_state_id,
        :district_name,
        :sub_district_name,
        :sub_district_id,
      	:village,
      	:event_date,
      	:participant_amount,
      	:content,
        {:languages => []},
        {:purposes => []},
        :people_attributes => [:id, :name],
        :reports_attributes => [
            :id,
            :content,
            :impact_report,
            :planning_report,
            :observers_attributes => [:id, :name],
            :languages => []
        ],
        :action_points_attributes => [:id, :content, :responsible]
      	)
    end

end
