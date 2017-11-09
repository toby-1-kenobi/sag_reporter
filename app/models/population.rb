class Population < ActiveRecord::Base
  belongs_to :language, inverse_of: :populations
  validates :amount, presence: true
  validates :language, presence: true

  def to_s
    number = ActiveSupport::NumberHelper.number_to_delimited(amount)
    if source.present? or year.present?
      source_str = "#{year} #{source}".strip
      return "#{number} (#{source_str})"
    else
      return number
    end
  end
end
