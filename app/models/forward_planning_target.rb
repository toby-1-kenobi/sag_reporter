class ForwardPlanningTarget < ActiveRecord::Base
  belongs_to :topic
  belongs_to :state_language
end
