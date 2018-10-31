class Book < ActiveRecord::Base
  has_many :chapters, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validates :abbreviation, presence: true, uniqueness: true
  # 81 books can accommodate the canon of the Ethiopic Church
  validates :number, presence: true, inclusion: 1..81
  validates :nt, inclusion: [true, false]
end
