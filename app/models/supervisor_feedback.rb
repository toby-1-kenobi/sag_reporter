class SupervisorFeedback < ActiveRecord::Base
  belongs_to :ministry
  belongs_to :supervisor, class_name: 'User'
  belongs_to :facilitator, class_name: 'User'
  validates :month, presence: true, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'" }
  validates :facilitator, presence: true
  validates :ministry, presence: true
  validates :supervisor, presence: true
end
