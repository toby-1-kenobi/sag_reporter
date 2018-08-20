class ChurchMinistry < ActiveRecord::Base
  belongs_to :church_congregation
  belongs_to :ministry
  validates :church_congregation, presence: true
  validates :ministry, presence: true
end
