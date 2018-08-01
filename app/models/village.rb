class Village < ActiveRecord::Base
  belongs_to :geo_state
  has_many :church_congregations, dependent: :destroy
  has_many :village_languages, dependent: :destroy
  has_many :languages, through: :village_languages
  has_many :village_workers, dependent: :destroy
  has_many :workers, through: :village_workers

  delegate :name, to: :geo_state, prefix: 'state'

  validates :name, presence: true
end
