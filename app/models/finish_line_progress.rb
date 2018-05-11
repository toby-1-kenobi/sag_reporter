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
  def progress_level
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

end
