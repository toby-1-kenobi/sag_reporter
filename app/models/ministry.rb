class Ministry < ActiveRecord::Base

  has_many :ministry_markers, dependent: :destroy
  has_many :ministry_workers, dependent: :destroy
  has_many :workers, through: :ministry_workers
  has_many :church_ministries, dependent: :destroy
  has_many :church_teams, through: :church_ministries
  belongs_to :topic

  validates :name, presence: true

end
