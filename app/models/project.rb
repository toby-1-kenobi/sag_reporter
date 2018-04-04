class Project < ActiveRecord::Base
  has_many :languages
  validates :name, presence: true, uniqueness: true
end
