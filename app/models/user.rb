class User < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 50 }
  validates :phone, presence: true, length: { is: 10 }, format: { with: /\A\d+\Z/ }, uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
end
