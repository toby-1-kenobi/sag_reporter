class Project < ActiveRecord::Base
  has_many :languages, dependent: :nullify
  has_many :state_projects, dependent: :destroy
  has_many :geo_states, through: :state_projects
  has_many :reports, dependent: :nullify
  has_many :project_streams, dependent: :destroy
  has_many :ministries, through: :project_streams
  has_many :supervisors, through: :project_streams, class_name: 'User'
  validates :name, presence: true, uniqueness: true
end
