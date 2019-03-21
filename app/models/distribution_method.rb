class DistributionMethod < ActiveRecord::Base
  validates :name, presence: true
  has_many :translation_distributions, dependent: :destroy
end
