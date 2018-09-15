class ChurchTeam < ActiveRecord::Base

  belongs_to :organisation
  belongs_to :state_language
  has_many :church_ministries, dependent: :destroy
  has_many :ministries, through: :church_ministries
  has_many :church_team_memberships, dependent: :destroy
  has_many :users, through: :church_team_memberships

  validates :village, presence: true
  validates :state_language, presence: true

  def full_name
    description = "#{organisation ? organisation.name : 'independent church'} in #{village}"
    name.present? ? "#{name} (#{description})" : description
  end
end
