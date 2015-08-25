class ProgressUpdate < ActiveRecord::Base

  include StateBased
	
  belongs_to :user
  belongs_to :language_progress

end
