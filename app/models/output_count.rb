class OutputCount < ActiveRecord::Base

  include StateBased

  belongs_to :output_tally
  belongs_to :user
  belongs_to :language

  before_validation :date_init
  validate :language_must_be_in_state

  private

  def date_init
  	self.year ||= Date.today.year if new_record?
  	self.month ||= Date.today.month if new_record?
  end

  def language_must_be_in_state
    if !geo_state.languages.include? language
      errors.add(:language, "must be in the state selected")
    end
  end

end
