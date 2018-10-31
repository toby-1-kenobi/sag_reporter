class Chapter < ActiveRecord::Base
  belongs_to :book
  validates :book, presence: true
  validates :number, presence: true, inclusion: 1..150
  validates :verses, presence: true, inclusion: 1..176
end
