class Language < ActiveRecord::Base
  class << self
    attr_reader :translation_status_colour
  end

  enum translation_need: {
      survey_required: 0,
      no_translation_need: 1,
      limited_translation_need: 2,
      full_translation_need: 3,
      new_testament_published: 4,
      whole_bible_published: 5
  }
  enum translation_progress: {
      not_in_progress: 0,
      currently_in_progress: 1,
      in_progress_in_neighbouring_country: 3
  }

  @translation_status_colour = {
      work_in_progress: '#ffff00', #yellow
      scripture_available: '#00ff00', #green
      action_needed: '#ff0000', #red
      no_translation_need: '#4a86e8', #blue
      translation_progress_in_neighbouring_country: '#ff9900' #orange
  }

  #TODO: write tests for destroying languages so that when restriction applies other dependants don't get destroyed
  has_many :user_mt_speakers, class_name: 'User', foreign_key: 'mother_tongue_id', dependent: :restrict_with_error
  has_many :output_counts
  has_many :mt_resources, dependent: :restrict_with_error
  has_and_belongs_to_many :user_speakers, class_name: 'User'
  has_and_belongs_to_many :reports
  has_and_belongs_to_many :events
  has_many :state_languages, dependent: :destroy
  has_many :language_progresses, through: :state_languages
  has_many :progress_markers, through: :language_progresses
  has_many :geo_states, through: :state_languages
  has_many :organisation_engagements, dependent: :destroy
  has_many :engaged_organisations, through: :organisation_engagements, source: :organisation
  has_many :organisation_translations, dependent: :destroy
  has_many :translating_organisations, through: :organisation_translations, source: :organisation
  belongs_to :family, class_name: 'LanguageFamily'
  belongs_to :pop_source, class_name: 'DataSource'
  belongs_to :cluster
  has_many :language_names, dependent: :destroy
  has_many :dialects, dependent: :destroy
  has_many :finish_line_progresses, dependent: :destroy
  has_many :finish_line_markers, through: :finish_line_progresses
  belongs_to :champion, class_name: 'User', inverse_of: :championed_languages
  has_many :populations, dependent: :destroy, inverse_of: :language

  delegate :name, to: :family, prefix: true, allow_nil: true
  delegate :name, to: :cluster, prefix: true

  validates :name, presence: true, allow_nil: false, uniqueness: true
  validates :iso,
            length: { is: 3 },
            allow_blank: true,
            uniqueness: { case_sensitive: false }
  # when locale_tag is present the language can be used for the interface
  validates :locale_tag, presence: true, allow_nil: true

  before_validation do |language|
    language.iso.downcase! if language.iso.present?
    language.iso = nil if language.iso.blank?
  end

  scope :user_limited, -> user {
    if user.national?
      all
    else
      joins(:geo_states).where('geo_states.id' => user.geo_states).uniq('languages.id')
    end
  }

  def to_s
    name
  end

  # This method is intended to be run daily
  # It finds the languages that haven't been updated recently
  # and for which the champions haven't been recently prompted
  # and sends out email prompts for the champions to check they are up to date
  def self.prompt_champions

    # Some users may be champion of many languages. We don't want to overload
    # their inboxes with lots of emails, so we combine into one email per user.
    # One problem would be that a user with many languages may have their languages
    # "mature" on different days so would still get lots of emails. To alleviate this,
    # languages that will mature in the next 5 days whose champion also has languages
    # that are already mature will be triggered early. Also champions with maturing
    # languages that also has languages 5-10 days out from maturing will not have any of
    # their languages trigger until those languages move out of that bracket, unless
    # that user has languages more than 10 days past their mature date.
    # Each user wont receive more than one prompt in a 10 day period.

    # trigger is normally at least 30 days after most recent update and 30 days after most recent prompt.
    most_recent = 20.days.ago
    recent = 25.days.ago
    standard = 30.days.ago
    overdue = 40.days.ago
    # Start by collecting languages 20 days old on both counts
    languages = Language.
        where.not(champion: nil).
        where('champion_prompted <= ?', most_recent).
        where('updated_at <= ?', most_recent)

    # group by champion and pair languages with their change date
    # change date is refined to account for edits not approved.
    # We can discard languages with change more recent than 20 days
    # Group the other languages in brackets of when they should trigger
    champions = {}
    languages.each do |language|
      change_date = language.last_changed
      if change_date <= most_recent
        champions[language.champion_id] ||= {
            most_recent: [],
            recent: [],
            standard: [],
            overdue: []
        }
        trigger_date = language.champion_prompted ? [change_date, language.champion_prompted].max : change_date
        case
          when trigger_date < overdue
            champions[language.champion_id][:overdue] << [language, change_date]
          when trigger_date <= standard
            champions[language.champion_id][:standard] << [language, change_date]
          when trigger_date <= recent
            champions[language.champion_id][:recent] << [language, change_date]
          else
            champions[language.champion_id][:most_recent] << [language, change_date]
        end
      end
    end

    # Champions assigned to a new language should be prompted
    # regardless of when the language was last updated.
    # we'll put these in the overdue category to make sure they trigger
    languages = Language.where.not(champion: nil).where(champion_prompted: nil)
    languages.each do |language|
      champions[language.champion_id] ||= {
          most_recent: [],
          recent: [],
          standard: [],
          overdue: []
      }
      change_date = language.last_changed
      champions[language.champion_id][:overdue] << [language, change_date]
    end

    # Trigger on the correct languages
    champions.each do |champion_id, languages|
      # if no languages have reached the standard trigger date, then trigger none
      # if languages are in the most_recent bracket and none are overdue, then trigger none
      if (languages[:standard].empty? or languages[:most_recent].any?) and languages[:overdue].empty?
        champions.delete champion_id
      else
        # otherwise good to go on all brackets except the most_recent
        languages.delete :most_recent
        UserMailer.prompt_champion(User.find(champion_id), languages.values.reduce([], :concat)).deliver_now
      end
    end

  end

  # the filter param is a string of tokens separated by '-'
  # the first token is a comma separated list of finish line marker numbers representing visible columns in the table
  # after that each token corresponds to a visible column and defines the selected filters on that column. No sperator is used
  # the selected filters are indicated by the id of the flm status
  def self.parse_filter_param
    #TODO: what happens if an invalid string comes in?
    flm_filters = {}
    tokens = params[:filter].split('-')
    tokens.shift.split(',').each do |flm_number|
      next_token = tokens.shift
      flm_filters[flm_number] = next_token ? next_token.split('') : []
    end
    return flm_filters
  end

  # this for when the filters are not not provided in the parameters
  def self.use_default_filters
    flm_filters = {}
    ['1', '2', '4', '5', '6', '7', '8', '9'].each do |flm_number|
      flm_filters[flm_number] = ['0', '1', '2', '3', '4', '5', '6']
    end
    return flm_filters
  end

  def self.minorities(geo_states = nil)
    if geo_states
      includes(:geo_states).where(lwc: false, 'geo_states.id' => geo_states.map{ |s| s.id })
    else
      where(lwc: false)
    end
  end

  def self.interface_fallback
    Language.find_by_name('English') || Language.take
  end

  def geo_state_ids_str
    geo_state_ids.join ','
  end

  def best_current_pop
    # This is Postgresql dependent
    # to get the biggest non-null year
    populations.order('year DESC NULLS LAST, created_at DESC').first
  end

  # latest date of a modification or suggested edit
  def last_changed
    edits = Edit.where(model_klass_name: 'Language', record_id: id).where('created_at > ?', updated_at).order(:created_at)
    edits.any? ? edits.last.created_at : updated_at
  end

  # should probably have a scope for each of these. It would help with the overview page
  def translation_status
    case
      when translation_need == 'new_testament_published', translation_need == 'whole_bible_published'
        :scripture_available
      when translation_progress == 'in_progress_in_neighbouring_country'
        :translation_progress_in_neighbouring_country
      when translation_progress == 'currently_in_progress'
        :work_in_progress
      when translation_need == 'no_translation_need'
        :no_translation_need
      else
        :action_needed
    end
  end

  def translation_status_colour
    Language.translation_status_colour[translation_status]
  end

  def table_data(geo_state, user, options = {})
    options[:from_date] ||= 6.months.ago
    options[:to_date] ||= Date.today
    dates_by_month = (options[:from_date].to_date..options[:to_date].to_date).select{ |d| d.day == 1}

    table = Array.new

    headers = ['Outputs']
    dates_by_month.each{ |date| headers.push(date.strftime('%B %Y')) }
    table.push(headers)

    OutputTally.all.order(:topic_id).each do |tally|
      unless tally.topic.hide_for?(user)
        row = [tally.description]
        dates_by_month.each do |date|
          row.push(tally.total(geo_state, [self], date.year, date.month))
        end
        table.push(row)
      end
    end

    resources_row = ['Number of tools completed by the network']
    dates_by_month.each_with_index do |date, index|
      resources_row.push(MtResource.where(geo_state: geo_state, language: self, created_at: date..(dates_by_month[index + 1] || date + 1.month)).count)
    end
    table.push(resources_row)

    return table

  end

end
