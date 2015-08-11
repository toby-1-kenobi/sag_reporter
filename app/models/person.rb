class Person < ActiveRecord::Base

  include ContactDetails

  belongs_to :mother_tongue, class_name: "Language", foreign_key: "language_id"
  belongs_to :record_creator, class_name: "User", foreign_key: "user_id"
  has_many :attendances, dependent: :destroy
  has_many :events, through: :attendances
  has_many :action_points

  validates :name, presence: true, length: { maximum: 50 }
  validates :phone, length: { is: 10 }, allow_nil: true, numericality: true

end
