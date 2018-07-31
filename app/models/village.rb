class Village < ActiveRecord::Base
  belongs_to :geo_state
  has_many :church_congregations, dependent: :destroy

  validate :name, presence: true
end
