class User < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 50 }
  validates :phone, presence: true, length: { is: 10 }, format: { with: /\A\d+\Z/ }
end
