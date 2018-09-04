class ChurchMinistry < ActiveRecord::Base

  enum status: {
    active: 0,
    deleted: 1
  }

  belongs_to :church_team
  belongs_to :ministry
  has_many :ministry_outputs, dependent: :restrict_with_exception
  has_many :reports, dependent: :nullify

  validates :church_team, presence: true
  validates :ministry, presence: true

end
