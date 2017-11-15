class Population < ActiveRecord::Base
  belongs_to :language, inverse_of: :populations
  validates :amount, presence: true
  validates :language, presence: true
  validate :year_within_sensible_range

  def to_s
    number = ActiveSupport::NumberHelper.number_to_delimited(amount)
    if source.present? or year.present?
      source_str = "#{year} #{source}".strip
      return "#{number} (#{source_str})"
    else
      return number
    end
  end

  private

  def year_within_sensible_range
    # we're not interested in anyone's opinion of populations in India before 1500
    if year < 1500
      errors.add(:year, 'too early')
    end
    if year > Date.today.year
      errors.add(:year, 'too futuristic')
    end
  end
end
