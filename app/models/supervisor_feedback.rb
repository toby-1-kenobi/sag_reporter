class SupervisorFeedback < ActiveRecord::Base

  has_paper_trail

  enum facilitator_progress: {
    no_progress: 0,
    poor: 1,
    fair: 2,
    good: 3,
    excellent: 4
  }

  belongs_to :state_language
  belongs_to :ministry
  belongs_to :supervisor, class_name: 'User'
  belongs_to :facilitator, class_name: 'User'

  validates :month, presence: true, format: { with: /\A[2-9]\d{3}-(0|1)[0-9]\z/, message: "should be in the format 'YYYY-MM'" }
  validates :facilitator, presence: true, uniqueness: { scope: [:ministry_id, :facilitator_id, :month] }
  validates :ministry, presence: true
  validates :supervisor, presence: true
  validates :report_approved, inclusion: [true, false]

  scope :not_empty, -> { where('result_feedback IS NOT NULL OR facilitator_progress IS NOT NULL OR report_approved = true') }

  before_create :check_for_duplicates

  def check_for_duplicates
    entry = self
    entries = SupervisorFeedback.where(month: entry.month, ministry_id: entry.ministry_id, facilitator_id: entry.facilitator_id, state_language_id: entry.state_language_id).order(updated_at: :desc)
    if entries.size > 0
      entry.id = entries.first.id
      entries.each &:destroy
    end
  end

end
