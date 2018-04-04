class Project < ActiveRecord::Base
  has_many :languages, dependent: :nullify
  validates :name, presence: true, uniqueness: true
end
