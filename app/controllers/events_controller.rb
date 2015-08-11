class EventsController < ApplicationController

  before_action :require_login

  autocomplete :person, :name
  
  def new
  	@event = Event.new()
  	@minority_languages = Language.where(lwc: false)
  	@all_purposes = Purpose.all
  end

  def create
  	errors = Array.new
    @event = Event.new(event_params)
    if @event.save
      # link the people to the event
      person_params = params.select{ |param| param[/^person__\d+$/] }
      person_params.each do |person_name|
      	@event.people << Person.find_or_create_by(name: person_name)
      end
      # link the languages to the event
      params['event']['languages'].each do |lang_id, value|
      	if value then @event.languages << Language.find(lang_id) end
      end
      # link the purposes to the event
      params['event']['purposes'].each do |purp_id, value|
      	if value then @event.purposes << Purpose.find(purp_id) end
      end
      # create all the reports and link them to the event
      Event.yes_no_questions.each_key do |code|
      	if params[code] == 'yes'
      	  content = Hash[params.select{ |param| param[/^#{code}\-response__\d+$/] }.map{ |k,v| [k.gsub(/\d+$/),v] }]
      	  report_type = Hash[params.select{ |param| param[/^#{code}\-type__\d+$/] }.map{ |k,v| [k.gsub(/\d+$/),v] }]
      	  report_languages = Hash[params.select{ |param| param[/^#{code}\-lang__\d+$/] }.map{ |k,v| [k.gsub(/\d+$/),v] }]
      	  content.each do |key, value|
      	  	report_params = {
      	  		content: value,
      	  	  	reporter: current_user,
      	  	  	event: @event
      	  	  }
      	  	unless code == 'plan' || code == 'impact' then report_params[code] = true end
      	  	if report_type[key] = "impact"
      	  	  ImpactReport.create(report_params) or errors << "could not create impact report: " + content.slice(0..20)
      	  	else
      	  	  Report.create(report_params) or errors << "could not create planning report: " + content.slice(0..20)
      	  	end
      	  end
      	end
      end
      # Create the action points

      # show errors as a flash if any
      if !errors.empty?
      	flash['error'] = errors.join('<br/>'.html_safe)
      end
      redirect_to @event
    else
  	  @minority_languages = Language.where(lwc: false)
  	  @all_purposes = Purpose.all
  	  render 'new'
  	end

  end

  def show
  	@event = Event.find(params[:id])
  end

  private

    def event_params
      params.require('event').permit(
      	:event_label,
      	:district,
      	:sub_district,
      	:village,
      	:event_date,
      	:participant_amount,
      	:content
      	)
    end

end
