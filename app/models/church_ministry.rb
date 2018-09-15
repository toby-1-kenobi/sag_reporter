class ChurchMinistry < ActiveRecord::Base

  enum status: {
    active: 0,
    deleted: 1
  }

  belongs_to :church_team
  belongs_to :ministry
  belongs_to :language
  belongs_to :language_stream
  has_many :ministry_outputs, dependent: :restrict_with_exception
  has_many :reports, dependent: :nullify
  has_many :facilitator_feedbacks, dependent: :destroy

  validates :church_team, presence: true
  validates :ministry, presence: true
  validates :language, presence: true

end
