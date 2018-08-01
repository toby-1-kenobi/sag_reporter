class Ministry < ActiveRecord::Base

  has_many :ministry_markers, dependent: :destroy
  has_many :ministry_workers, dependent: :destroy
  has_many :workers, through: :ministry_workers

  validates :name, presence: true

end