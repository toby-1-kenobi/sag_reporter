class AppBenefit < ActiveRecord::Base
  has_many :user_benefits, dependent: :destroy

  validates :name, presence: true
end
