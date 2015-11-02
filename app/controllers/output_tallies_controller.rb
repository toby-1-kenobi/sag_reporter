class OutputTalliesController < ApplicationController

  before_action :require_login

  def report_numbers
  	@output_tallies_by_topic = OutputTally.all.group_by{ |ot| ot.topic }
  	@languages = Language.minorities(current_user.geo_states)
  end

  def update_numbers

  	month = params['date']['month'].to_i
  	year = Date.today.year
  	if month > Date.today.month then year = year - 1 end

    geo_state = GeoState.find(params['outputs']['geo_state'])

  	params['amounts'].select{ |k,v| v and params[k] and not params[k].empty? }.each do |code, amount|
  	  language = Language.find(params[code])
  	  tally = OutputTally.find(code.split('__').first)
  	  OutputCount.create(
  	  	user: current_user,
        geo_state: geo_state,
  	  	output_tally: tally,
  	  	language: language,
  	  	amount: amount,
  	  	year: year,
  	  	month: month
  	  )
  	end
  	flash.now['success'] = "Numbers recorded"
  	render 'static_pages/home'

  end

  def table
  	@languages = Language.minorities(current_user.geo_states)
  end

end
