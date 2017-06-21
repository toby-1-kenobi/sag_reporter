class FinishLineProgress < ActiveRecord::Base

  enum status: {
      # 0-3 are options for not done markers
      no_need: 0,
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

  def to_s
    "#{finish_line_marker.name} for #{language.name}"
  end

  def self.category(status)
    case status
      when 'no_need'
        :nothing
      when 'possible_need', 'expressed_needs'
        :no_progress
      when 'in_progress'
        :progress
      else
        :complete
    end
  end

  def category
    FinishLineProgress.category(status)
  end

  def human_status
    if finish_line_marker.number == 0
      FinishLineProgress.church_engagement_status[status]
    else
      case status
        when 'no_need'
          'No need'
        when 'possible_need', 'expressed_needs'
          "#{status.humanize}, not started"
        when 'in_progress'
          'In progress, not completed'
        when 'completed'
          case finish_line_marker.number
            when 2, 3, 4, 8, 9, 10
              'Reached requirements'
            else
              'Completed'
          end
        else
          case finish_line_marker.number
            when 2, 3, 4, 8, 9, 10
              "Reached requirements, #{status.humanize}"
            else
              "Completed, #{status.humanize}"
          end
      end
    end
  end

  def simple_human_status
    if finish_line_marker.number == 0
      FinishLineProgress.church_engagement_status[status]
    else
      if status == 'completed'
        case finish_line_marker.number
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

  def self.human_of_status(status, marker_number)
    # possible_need used to be called potential_need
    if status == 'potential_need' then status = 'possible_need' end
    if marker_number == 0
      church_engagement_status[status]
    else
      case status
        when 'no_need'
          'No need'
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

  def self.church_engagement_status
    {
        'no_need' => 'No churches',
        'possible_need' => 'No use',
        'in_progress' => 'Few churches using',
        'completed' => 'Many churches using',
        'further_work_in_progress' => 'Church running project'
    }
  end

end
