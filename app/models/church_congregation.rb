class ChurchCongregation < ActiveRecord::Base
  belongs_to :organisation
  has_many :users, dependent: :nullify
  has_many :ministry_outputs, dependent: :destroy
  has_many :church_ministries, dependent: :destroy
  has_many :ministries, through: :church_ministries

  validates :village, presence: true, uniqueness: { scope: :organisation }

  def full_name
    description = "#{organisation ? organisation.name : 'independent church'} in #{village}"
    name.present? ? "#{name} (#{description})" : description
  end
end
