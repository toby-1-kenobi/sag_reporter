class OutputTalliesController < ApplicationController

  before_action :require_login

  def report_numbers
  	@output_tallies_by_topic = OutputTally.all.group_by{ |ot| ot.topic }
  	@languages = Language.minorities
  end

end
