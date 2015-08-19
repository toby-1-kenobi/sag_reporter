class Language < ActiveRecord::Base

  has_many :user_mt_speakers, class_name: 'User', foreign_key: 'mother_tongue_id'
  has_and_belongs_to_many :user_speakers, class_name: 'User'
  has_and_belongs_to_many :reports
  has_many :language_tallies, class_name: 'LanguagesTally', dependent: :destroy
  has_and_belongs_to_many :impact_reports
  has_many :tallies, through: :language_tallies
  has_and_belongs_to_many :events
  has_many :language_progresses, dependent: :destroy
  has_many :progress_markers, through: :language_progresses
  has_many :output_counts

  validates :name, presence: true, allow_nil: false, uniqueness: true

  def self.minorities
    where(lwc: false)
  end

    def table_data(options = {})
    options[:from_date] ||= 1.year.ago - 1.month
    options[:to_date] ||= 1.month.ago
    dates_by_month = (options[:from_date].to_date..options[:to_date].to_date).select{ |d| d.day == 1}

    table = Array.new

    headers = ["Outputs"]
    dates_by_month.each{ |date| headers.push(date.strftime("%B %Y")) }
    table.push(headers)

    OutputTally.all.order(:topic_id).each do |tally|
      row = [tally.description]
      dates_by_month.each do |date|
        row.push(tally.total([self], date.year, date.month))
      end
      table.push(row)
    end

    return table

  end
	
end
