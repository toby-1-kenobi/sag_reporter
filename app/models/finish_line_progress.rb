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

  after_update :ripple_status_change, if: :status_changed?

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

  # give a progress level by status
  # to define which statuses represents further progress or less.
  # This is needed for future planning
  # When setting a status in a year where later years exist
  # then the same status should be set in later years as long as it's not a backwards step
  def self.progress_level(status)
    case status
    when 'possible_need', 'no_need', 'not_accessible'
      1
    when 'expressed_needs'
      2
    when 'in_progress'
      3
    when 'completed'
      4
    when 'further_needs_expressed'
      5
    when 'further_work_in_progress'
      6
    else
      7
    end
  end

  def progress_level
    FinishLineProgress.progress_level(status)
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
        'No action needed'
      when 'not_accessible'
        'Language not accessible'
      when 'possible_need', 'expressed_needs'
        if marker_number == 7 # OT
          if status == 'possible_need'
            'Possible need (not V2033)'
          else
            'Target is OT by 2033'
          end
        else
          "#{status.humanize}, not started"
        end
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
      case status
      when 'completed'
        case marker_number
        when 2, 3, 4, 8, 9, 10
          'Reached requirements'
        else
          'Completed'
        end
      when 'no_need'
        'No action needed'
      when 'expressed_needs'
        if marker_number == 7 # OT
          'Target V2033'
        else
          status.humanize
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

  private

  def ripple_status_change
    this_year = year || ApplicationController.helpers.get_current_year
    # and there exists an flp in the following for the same language and marker
    next_year = FinishLineProgress.find_by(
        language_id: language_id,
        finish_line_marker_id: finish_line_marker_id,
        year: this_year + 1
    )
    # and that flp has an equal or lower progress level
    if next_year and next_year.progress_level <= progress_level
      # then ripple this status on to the next
      next_year.update_attribute(:status, status)
    end
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
