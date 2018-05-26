class FinishLineProgress < ActiveRecord::Base

  enum status: {
      # 0-3 are options for not done markers
      no_need: 0,
      not_accessible: 7,
      possible_need: 1,
      expressed_needs: 2,
      in_progress: 3,
      outside_india_in_progress: 8,
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
  after_create :fill_gaps

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
      when 'in_progress', 'outside_india_in_progress'
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
    when 'in_progress', 'outside_india_in_progress'
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
      when 'possible_need'
        if marker_number == 7 # OT
          'Possible need (not V2033)'
        else
          'Survey needed'
        end
      when 'expressed_needs'
        if marker_number == 7 # OT
          'Target is OT by 2033'
        else
          "#{status.humanize}, not started"
        end
      when 'in_progress'
        'In progress, not completed'
      when 'outside_india_in_progress'
        'In progress outside India'
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
      when 'possible_need'
        'Survey needed'
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

  private

  # If we've created a future FLP and there's years
  # between current and the year for this FLP that don't have
  # FLPs for this language and marker
  # fill in those years
  def fill_gaps
    if year
      attributes = { language_id: language_id, finish_line_marker_id: finish_line_marker_id, year: nil }
      last = FinishLineProgress.find_or_create_by(attributes)
      year_index = FinishLineProgress.get_current_year + 1
      while (year_index < year)
        Rails.logger.debug("year: #{year}, year_index: #{year_index}")
        attributes[:year] = year_index
        last = FinishLineProgress.create_with(status: last.status).find_or_create_by(attributes)
        year_index += 1
      end
    end
  end

  def ripple_status_change
    this_year = year || FinishLineProgress.get_current_year
    # and there exists an flp in the following year for the same language and marker
    # # if there's not one in the following, but in later year - get that
    next_year = FinishLineProgress.where(
        language_id: language_id,
        finish_line_marker_id: finish_line_marker_id,
    ).where('year > ?', this_year).order(:year).first
    # and that flp has an equal or lower progress level
    if next_year and next_year.progress_level <= progress_level
      # then ripple this status on to the next
      next_year.update_attribute(:status, status)
    end
  end

end
