class Project < ActiveRecord::Base
  has_many :languages, dependent: :nullify
  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users
  has_many :reports, dependent: :nullify
  validates :name, presence: true, uniqueness: true
end
