class ProgressMarker < ActiveRecord::Base

  belongs_to :topic
  has_many :language_progresses, dependent: :destroy
  has_many :languages, through: :language_progresses 
  has_and_belongs_to_many :impact_reports

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

  def language_progress(state_language)
    LanguageProgress.where(progress_marker: self, state_language: state_language).first or LanguageProgress.create(progress_marker: self, state_language: state_language)
  end

  def progress_at(state_language, date = nil)
    language_progress(state_language).value_at(date)
  end

end
