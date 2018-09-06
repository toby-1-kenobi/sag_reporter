class Project < ActiveRecord::Base
  has_many :languages, dependent: :nullify
  has_many :project_users, dependent: :destroy
  has_many :users, through: :project_users
  has_many :reports, dependent: :nullify
  has_many :project_streams, dependent: :destroy
  has_many :ministries, through: :project_streams
  has_many :supervisors, through: :project_streams, class_name: 'User'
  validates :name, presence: true, uniqueness: true
end
