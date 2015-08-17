class ProgressUpdate < ActiveRecord::Base
	
  belongs_to :user
  belongs_to :language_progress

end
