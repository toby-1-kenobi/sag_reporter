class TranslationDistribution < ActiveRecord::Base
  belongs_to :distribution_method
  belongs_to :language

  validates :language_id, presence: true
  validates :distribution_method_id, presence: true
end
