class OutputCount < ActiveRecord::Base

  include StateBased

  belongs_to :output_tally
  belongs_to :user
  belongs_to :language

  after_initialize :date_init
  validates :language, presence: true
  validate :language_must_be_in_state
  validates :amount, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :output_tally, presence: true
  validates :user, presence: true
  validates :year, presence: true
  validates :month, presence: true

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
