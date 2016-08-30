class Cluster < ActiveRecord::Base
  has_many :languages
  validates :name, presence: true, allow_nil: false, uniqueness: true
end
