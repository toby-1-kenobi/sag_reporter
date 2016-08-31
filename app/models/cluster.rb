class Cluster < ActiveRecord::Base
  has_many :languages, dependent: :nullify
  validates :name, presence: true, allow_nil: false, uniqueness: true
end
