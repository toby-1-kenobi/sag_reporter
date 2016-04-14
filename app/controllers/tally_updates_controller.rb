class TallyUpdatesController < ApplicationController
  
  def index
  end

  def create
  	@update = TallyUpdate.new(update_params)
  	if @update.save
  		flash["success"] = "Tally update succeeded"
  	else
  		flash["error"] = "Tally update failed"
  	end
  	redirect_to :controller => 'tallies', :action => 'show', id: params[:tally_update][:tally_id]
  end

  private

    def update_params
    	{
    		amount: params[:tally_update][:amount],
    		languages_tally_id: LanguagesTally.where(tally_id: params[:tally_update][:tally_id], language_id: params[:tally_update][:language_id]).take.id,
    		user_id: logged_in_user.id
    	}
    end

end
