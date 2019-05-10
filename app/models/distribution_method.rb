class DistributionMethod < ActiveRecord::Base

  has_paper_trail

  validates :name, presence: true
  has_many :translation_distributions, dependent: :destroy
end
