class ChurchCongregation < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :village, uniqueness: { scope: :organisation }
  has_many :users, dependent: :nullify
  has_many :planned_ministries, dependent: :destroy
  has_many :actual_ministries, dependent: :destroy

  def full_name
    description = "#{organisation ? organisation.name : 'independent church'} in #{village.name}"
    name.present? ? "#{name} (#{description})" : description
  end
end