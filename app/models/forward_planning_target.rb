class ForwardPlanningTarget < ActiveRecord::Base
  has_many :topic
  has_many :language_progresses
end
