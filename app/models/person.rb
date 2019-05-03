class Person < ActiveRecord::Base

  has_paper_trail

  include ContactDetails
  include StateBased

  belongs_to :mother_tongue, class_name: "Language", foreign_key: "language_id"
  belongs_to :record_creator, class_name: "User", foreign_key: "user_id"
  has_many :creations, dependent: :destroy
  has_many :mt_resources, through: :creations
  has_many :observations, inverse_of: :person, dependent: :destroy
  has_many :reports, through: :observations

  validates :name, presence: true, length: { maximum: 50 }
  validates :phone, length: { is: 10 }, allow_nil: true, numericality: true

end
