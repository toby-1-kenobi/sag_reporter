class Facilitator < ActiveRecord::Base
  belongs_to :user
  has_many :facilitator_languages, dependent: :destroy
  has_many :languages, through: :facilitator_languages
  has_many :facilitator_streams, dependent: :destroy
  has_many :ministries, through: :facilitator_streams
  has_many :church_ministries, dependent: :restrict_with_error
  validates :user, presence: true
end
