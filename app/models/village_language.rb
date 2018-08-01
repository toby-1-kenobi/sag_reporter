class VillageLanguage < ActiveRecord::Base

  belongs_to :village
  belongs_to :language

  validates :village, presence: true
  validates :language, presence: true
  validate :language_in_state

  private

  def language_in_state
    if village and language
      if village.geo_state.present?
        errors.add(:language, "must be spoken in #{village.state_name}") unless village.geo_state.languages.include? language
      else
        errors.add(:village, 'must be in a state')
      end
    end
  end

end
