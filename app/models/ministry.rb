class Ministry < ActiveRecord::Base

  has_many :deliverables, dependent: :destroy
  has_many :quarterly_targets, through: :deliverables
  has_many :aggregate_deliverables, dependent: :destroy
  has_many :language_streams, dependent: :destroy
  has_many :facilitators, through: :language_streams, class_name: 'User'
  has_many :church_ministries, dependent: :destroy
  has_many :church_teams, through: :church_ministries
  has_many :project_streams, dependent: :destroy
  has_many :projects, through: :project_streams
  has_many :supervisors, through: :project_streams, class_name: 'User'
  belongs_to :topic

  validates :number, presence: true, uniqueness: true

  # key for the l10n translation of the description
  # is 'm_xx' where 'xx' is a 2-digit representation of the number
  def translation_key
    "m_#{sprintf('%02d', number)}"
  end

  def name
    I18n.t("ministries.names.#{translation_key}")
  end

end
