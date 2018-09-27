class Project < ActiveRecord::Base
  has_many :project_languages, dependent: :destroy
  has_many :state_languages, through: :project_languages
  has_many :geo_states, through: :state_languages
  has_many :zones, through: :geo_states
  has_many :reports, dependent: :nullify
  has_many :project_supervisors, dependent: :destroy
  has_many :supervisors, through: :project_supervisors, class_name: 'User', foreign_key: 'user_id'
  has_many :project_streams, dependent: :destroy
  has_many :ministries, through: :project_streams
  has_many :stream_supervisors, through: :project_streams, class_name: 'User', foreign_key: 'supervisor_id'
  has_many :language_streams, dependent: :nullify
  has_many :facilitators, through: :language_streams, class_name: 'User'
  validates :name, presence: true, uniqueness: true
end
