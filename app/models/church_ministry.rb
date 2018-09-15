class ChurchMinistry < ActiveRecord::Base

  enum status: {
    active: 0,
    deleted: 1
  }

  belongs_to :church_team
  belongs_to :ministry
  belongs_to :facilitator, class_name: 'User'
  has_many :ministry_outputs, dependent: :restrict_with_exception
  has_many :reports, dependent: :nullify
  has_many :facilitator_feedbacks, dependent: :destroy

  validates :church_team, presence: true
  validates :ministry, presence: true
  validate :facilitator_is_facilitator

  private

  def facilitator_is_facilitator
    if facilitator.present?
      errors.add(:facilitator, 'is not a facilitator') unless facilitator.facilitator?
    end
  end

end
