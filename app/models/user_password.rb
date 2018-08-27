class UserPassword < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :password, presence: true
end
