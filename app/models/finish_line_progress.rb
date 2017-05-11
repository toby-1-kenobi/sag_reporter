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

  def category
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
          'Completed'
        else
          "Completed, #{status.humanize}"
      end
    end
  end

  def simple_human_status
    if finish_line_marker.number == 0
      FinishLineProgress.church_engagement_status[status]
    else
      status.humanize
    end
  end

  def self.human_of_status(status, church_engagement)
    # possible_need used to be called potential_need
    if status == 'potential_need' then status = 'possible_need' end
    if church_engagement
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
          'Completed'
        when 'further_needs_expressed', 'further_work_in_progress'
          "Completed, #{status.humanize}"
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

  def self.status_description(status, church_engagement)
    if church_engagement
      case status
        when 'no_need'
          'There are no local churches'
        when 'possible_need'
          'There are local churches but none are accepting and using the mother tongue materials for transformation'
        when 'in_progress'
          'Some local churches (a few only) are accepting and using the mother tongue materials for transformation'
        when 'completed'
          'Many local churches, from a range of denominations, are accepting and using the mother tongue materials for transformation'
        when 'further_work_in_progress'
          'Local churches are going beyond use, to resourcing and running the project themselves'
        else
          ''
      end
    else
      case status
        when 'no_need'
          'Material is not available, but based on the available information there is no need'
        when 'possible_need'
          'Material is not available, but could emerge as a potential need'
        when 'expressed_needs'
          'Material is not available, but there is a need (based on the research and/or through church request) to make the material available'
        when 'in_progress'
          'Work on the material is in progress'
        when 'completed'
          'Material is available and there is no further need expressed'
        when 'further_needs_expressed'
          'Even though the material is available, further need is expressed because of a dialect or script difference'
        when 'further_work_in_progress'
          'Even though the material is available, because of a dialect or script difference, work is in progress (in a different dialect or a script)'
        else
          ''
      end
    end
  end

end
