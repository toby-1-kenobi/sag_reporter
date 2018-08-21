class ChurchMinistry < ActiveRecord::Base

  belongs_to :church_congregation
  belongs_to :ministry
  has_many :ministry_outputs, dependent: :restrict_with_exception

  validates :church_congregation, presence: true
  validates :ministry, presence: true

end
