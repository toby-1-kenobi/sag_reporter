class Chapter < ActiveRecord::Base

  belongs_to :book
  has_many :translation_progresses, dependent: :destroy
  has_many :languages, through: :translation_progresses

  validates :book, presence: true
  validates :number, presence: true, inclusion: 1..150
  validates :verses, presence: true, inclusion: 1..176

end
