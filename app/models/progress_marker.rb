class ProgressMarker < ActiveRecord::Base

  enum status: {
      active: 0,
      deprecated: 1
  }

  belongs_to :topic
  has_many :language_progresses, dependent: :destroy
  has_many :languages, through: :language_progresses 
  has_and_belongs_to_many :impact_reports

  validates :name, presence: true, uniqueness: true
  validates :topic, presence: true
  validates :number, allow_nil: true, uniqueness: true

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
    LanguageProgress.find_or_create_by(progress_marker: self, state_language: state_language)
  end

  def progress_at(state_language, date = nil)
    language_progress(state_language).value_at(date)
  end

  def description_for(user)
    if alternate_description.present? and user.sees_alternate_pm_descriptions?
      alternate_description
    else
      I18n.t("progress_markers.descriptions.#{translation_key}")
    end
  end

  def self.by_outcome_area_and_weight
    progress_markers_by_oa_and_weight = Hash.new
    self.active.includes(:topic).find_each do |pm|
      progress_markers_by_oa_and_weight[pm.topic] ||= weight_text.values.map{ |v| [v, Array.new] }.to_h
      progress_markers_by_oa_and_weight[pm.topic][weight_text[pm.weight]].push pm
    end
    return progress_markers_by_oa_and_weight
  end

  # key for the l10n translation of the description
  # is 'pm_xx' where 'xx' is a 2-digit representation of the number
  def translation_key
    "pm_#{sprintf('%02d', number)}"
  end

end
