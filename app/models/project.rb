class Project < ActiveRecord::Base
  has_many :state_projects, dependent: :destroy
  has_many :geo_states, through: :state_projects
  has_many :project_languages, dependent: :destroy
  has_many :state_languages, through: :project_languages
  has_many :geo_states, through:  :state_languages
  has_many :reports, dependent: :nullify
  has_many :project_streams, dependent: :destroy
  has_many :ministries, through: :project_streams
  has_many :supervisors, through: :project_streams, class_name: 'User'
  has_many :language_streams, dependent: :nullify
  has_many :facilitators, through: :language_streams, class_name: 'User'
  validates :name, presence: true, uniqueness: true
end
