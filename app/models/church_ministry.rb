class ChurchMinistry < ActiveRecord::Base

  belongs_to :church_team
  belongs_to :ministry
  has_many :ministry_outputs, dependent: :restrict_with_exception

  validates :church_team, presence: true
  validates :ministry, presence: true

end
