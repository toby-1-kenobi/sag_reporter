class FinishLineMarker < ActiveRecord::Base

  has_many :finish_line_progresses, dependent: :destroy
  has_many :languages, through: :finish_line_progresses

  validates :name, presence: true
  validates :description, presence: true
  validates :number, presence: true

end
