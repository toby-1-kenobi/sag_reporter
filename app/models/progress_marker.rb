class ProgressMarker < ActiveRecord::Base

  belongs_to :topic
  has_many :language_progresses, dependent: :destroy
  has_many :languages, through: :language_progresses 
  has_many :impact_reports

  def self.weight_text
  	{
  		1 => "Expect to see",
  		2 => "Like to see",
  		3 => "Love to see"
  	}
  end

  def self.spread_text
  	{
  		0 => "Not seen",
  		1 => "Emerging",
  		2 => "Growing well",
  		3 => "Widespread"
  	}
  end

  def language_progress(language)
    language_progresses.select{ |lp| lp.language == language }.first or LanguageProgress.create(progress_marker: self, language: language)
  end

  def current_progress(language)
    language_progress(language).current_value
  end

end
