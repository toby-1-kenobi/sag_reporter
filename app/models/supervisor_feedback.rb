class SupervisorFeedback < ActiveRecord::Base

  enum facilitator_progress: {
    no_result: 0,
    no_progress: 1,
    needs_attention: 2,
    good: 3
  }

  belongs_to :state_language
  belongs_to :ministry
  belongs_to :supervisor, class_name: 'User'
  belongs_to :facilitator, class_name: 'User'

  validates :month, presence: true, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'" }
  validates :facilitator, presence: true
  validates :ministry, presence: true
  validates :supervisor, presence: true
  validates :report_approved, inclusion: [true, false]

end
