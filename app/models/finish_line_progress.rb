class FinishLineProgress < ActiveRecord::Base

  enum status: {
      # 0-3 are options for not done markers
      no_need: 0,
      not_accessible: 7,
      possible_need: 1,
      expressed_needs: 2,
      in_progress: 3,
      # 4-6 are options for done markers
      completed: 4,
      further_needs_expressed: 5,
      further_work_in_progress: 6
  }

  belongs_to :language
  belongs_to :finish_line_marker

  validates :status, presence: true
  validates :language, presence: true
  validates :finish_line_marker, presence: true

  scope :languages, -> languages {
    where(language: languages)
  }

  def to_s
    "#{finish_line_marker.name} for #{language.name}"
  end

  def category
    FinishLineProgress.category(status)
  end

  def self.category(status)
    case status
      when 'no_need'
        :nothing
      when 'possible_need', 'expressed_needs', 'not_accessible'
        :no_progress
      when 'in_progress'
        :progress
      else
        :complete
    end
  end

  def human_status
    FinishLineProgress.human_of_status(status, finish_line_marker.number)
  end

  def self.human_of_status(status, marker_number)
    # possible_need used to be called potential_need
    if status == 'potential_need' then status = 'possible_need' end
    if marker_number == 0
      church_engagement_status[status]
    else
      case status
        when 'no_need'
          'No need'
        when 'not_accessible'
          'Language not accessible'
        when 'possible_need', 'expressed_needs'
          "#{status.humanize}, not started"
        when 'in_progress'
          'In progress, not completed'
        when 'completed'
          case marker_number
            when 2, 3, 4, 8, 9, 10
              'Reached requirements'
            else
              'Completed'
          end
        when 'further_needs_expressed', 'further_work_in_progress'
          case marker_number
            when 2, 3, 4, 8, 9, 10
              "Reached requirements, #{status.humanize}"
            else
              "Completed, #{status.humanize}"
          end
        else
          false
      end
    end
  end

  def simple_human_status
    FinishLineProgress.simple_human_of_status(status, finish_line_marker.number)
  end

  def self.simple_human_of_status(status, marker_number)
    if marker_number == 0
      FinishLineProgress.church_engagement_status[status]
    else
      if status == 'completed'
        case marker_number
          when 2, 3, 4, 8, 9, 10
            'Reached requirements'
          else
            'Completed'
        end
      else
        status.humanize
      end
    end
  end

  def self.church_engagement_status
    {
        'no_need' => 'No churches',
        'not_accessible' => 'Language not accessible',
        'possible_need' => 'No use',
        'in_progress' => 'Few churches using',
        'completed' => 'Many churches using',
        'further_work_in_progress' => 'Church running project'
    }
  end

  # find a finish line progress for a given language marker and year
  # if that doesn't exist find the one that matches language and marker
  # with maximum year less than the given year
  # when no markers of any year match find the one for current year (year == nil)
  def self.closest_to(language_id, flm_id, year)
    flp = where(language_id: language_id, finish_line_marker_id: flm_id).
        where('year <= ?', year ).
        where.not(year: nil).
        order(:year).last
    flp ||= find_by(language_id: language_id, finish_line_marker_id: flm_id, year: nil)
    flp
  end

  # find a finish line progress by the attributes
  # if it doesn't exist create it and create one for each year
  # leading up to the year in the attributes
  # status continues from most recent
  def self.find_or_create_in_sequence(attributes)
    flp = find_by attributes
    if flp
      flp
    else
      year = attributes.delete(:year).to_i
      return nil unless year # create in sequence requires 'year' attribute
      closest_flp = where(attributes).where.not(year: nil).order(:year).last
      if closest_flp
        start_year = closest_flp.year + 1
        status = closest_flp.status
      else
        start_year = get_current_year + 1
        Rails.logger.debug("attributes: #{attributes.merge(year: nil)}")
        current_flp = find_or_create_by(attributes.merge(year: nil))
        status = current_flp.status
      end
      while start_year <= year
        Rails.logger.debug "creating flp: #{start_year}"
        flp = FinishLineProgress.create(attributes.merge(year: start_year, status: status))
        start_year += 1
      end
    end
    flp
  end

  def self.get_current_year
    # year ticks over on October 1st
    year_cutoff_month = 10
    year_cutoff_day = 1
    current_year = Date.today.year
    cutoff_date = Date.new(current_year, year_cutoff_month, year_cutoff_day)
    if Date.today >= cutoff_date
      current_year + 1
    else
      current_year
    end
  end

end
