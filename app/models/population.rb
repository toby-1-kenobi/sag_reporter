class Population < ActiveRecord::Base
  belongs_to :language
  validates :amount, presence: true
  validates :language, presence: true
end
