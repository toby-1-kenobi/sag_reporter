class UserBenefit < ActiveRecord::Base
  belongs_to :user
  belongs_to :app_benefit

  validates :user, presence: true
  validates :app_benefit, presence: true, uniqueness: { scope: :user }
end
