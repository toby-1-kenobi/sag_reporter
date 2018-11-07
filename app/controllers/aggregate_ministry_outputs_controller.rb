class AggregateMinistryOutputsController < ApplicationController

  before_action :require_login

  def update_comment
    @amo = AggregateMinistryOutput.find params['amo_id']
    @amo.update_attributes(comment: params['comment'])
    respond_to :js
  end

end
