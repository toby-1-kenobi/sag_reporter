class TranslationDistribution < ActiveRecord::Base
  belongs_to :distribution_method
  belongs_to :translation_project

  validates :translation_project_id, presence: true
  validates :distribution_method_id, presence: true, uniqueness: {scope: :translation_project_id}
end
