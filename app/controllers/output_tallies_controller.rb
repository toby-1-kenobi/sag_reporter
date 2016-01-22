class OutputTalliesController < ApplicationController

  before_action :require_login

  def report_numbers
  	@output_tallies_by_topic = OutputTally.all.group_by{ |ot| ot.topic }
  	@languages = Language.minorities(current_user.geo_states).order("LOWER(languages.name)")
  end

  def update_numbers

  	month = params['date']['month'].to_i
  	year = Date.today.year
  	if month > Date.today.month then year = year - 1 end

    geo_state = GeoState.find(params['outputs']['geo_state_id'])

    @failedCounts = Array.new

  	params['amounts'].select{ |k,v| v and params[k] and not params[k].empty? }.each do |code, amount|
  	  language = Language.find(params[code])
  	  tally = OutputTally.find(code.split('__').first)
      outputCountParams = {
        user: current_user,
        geo_state: geo_state,
        output_tally: tally,
        language: language,
        amount: amount,
        year: year,
        month: month
      }
  	  outputCount = OutputCount.new(outputCountParams)
      if !outputCount.save
        @failedCounts << outputCount
      end
  	end
    if @failedCounts.length == 0
    	flash['success'] = "Thank you. Your numbers have been recorded."
    	redirect_to root_path
    else
      flash.now['error'] = "Some numbers could not be recorded"
      @output_tallies_by_topic = OutputTally.all.group_by{ |ot| ot.topic }
      @languages = Language.minorities(current_user.geo_states).order("LOWER(languages.name)")
      render 'report_numbers'
    end

  end

  def table
  	@languages = Language.minorities(current_user.geo_states).order("LOWER(languages.name)")
  end

end
