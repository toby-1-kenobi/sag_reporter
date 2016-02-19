class StateLanguage < ActiveRecord::Base

  belongs_to :geo_state
  belongs_to :language
  has_many :language_progresses
  has_many :progress_updates, through: :language_progresses

  validates :geo_state, presence: true
  validates :language, presence: true

  scope :in_project, -> { where project: true }

  def <=>(sl)
    language.name.downcase <=> sl.language.name.downcase
  end

  def outcome_table_data(options = {})
    options[:from_date] ||= 6.months.ago
    options[:to_date] ||= Date.today

    table = Hash.new
    table["Totals"] = Hash.new

    all_lps = language_progresses.includes(:progress_marker => :topic)
    all_lps.each do |lp|
      oa_name = lp.progress_marker.topic.name
      table[oa_name] ||= Hash.new
      lp.outcome_scores(options[:from_date], options[:to_date]).each do |date, score|
        table[oa_name][date] ||= 0
        table[oa_name][date] += score
        table["Totals"][date] ||= 0
        table["Totals"][date] += score
      end
    end

    return table
  end

end
