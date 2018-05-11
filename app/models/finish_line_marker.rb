class FinishLineMarker < ActiveRecord::Base

  has_many :finish_line_progresses, dependent: :destroy
  has_many :languages, through: :finish_line_progresses

  validates :name, presence: true
  validates :description, presence: true
  validates :number, presence: true

  scope :dashboard_visible, -> {
    where(number: [1, 2, 4, 5, 6, 7, 8, 10])
  }

  def status_description(status)
    case number
      when 0
        case status
          when 'no_need'
            'There are no local churches'
          when 'not_accessible'
            'Language community is not accessible'
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
      when 1, 5, 6, 7
        case status
          when 'no_need'
            'Material is not available, but based on the available information there is no need'
          when 'not_accessible'
            'Language community is not accessible'
          when 'possible_need'
            'Material is not available, but could emerge as a potential need'
          when 'expressed_needs'
            'Material is not available, but there is a need (based on the research and/or through community request) to make the material available'
          when 'in_progress'
            'Work on the material is in progress'
          when 'completed'
            'Material is available'
          when 'further_needs_expressed'
            'Even though the material is available, further need is expressed because of a dialect, script difference, quality issue, acceptability, special audiences, translation philosophy'
          when 'further_work_in_progress'
            'Even though the material is available, further work is in progress because of dialect or script difference, quality issue, acceptability, special audiences, translation philosophy'
          else
            ''
        end
      when 3
        case status
          when 'no_need'
            'No radio program being broadcast, but based on the available information there is no need'
          when 'not_accessible'
            'Language community is not accessible'
          when 'possible_need'
            'No radio program being broadcast, but could emerge as a potential need'
          when 'expressed_needs'
            'No radio program being broadcast, but there is a need (based on the research and/or through the community request) to make a radio program'
          when 'in_progress'
            'Work has started on a radio program but not broadcasting yet'
          when 'completed'
            'There is an ongoing radio program'
          when 'further_needs_expressed'
            'Radio program was broadcast earlier, but is now no longer broadcasting. Community has expressed need to start broadcasting again.'
          when 'further_work_in_progress'
            'Radio program was broadcast earlier, but no longer broadcasting. Work is in progress to start broadcasting again.'
          else
            ''
        end
      when 2, 3, 4, 8, 9, 10
        case status
          when 'no_need'
            'Material is not available, but based on the available information there is no need'
          when 'not_accessible'
            'Language community is not accessible'
          when 'possible_need'
            'Material is not available, but could emerge as a potential need'
          when 'expressed_needs'
            'Material is not available, but there is a need (based on the research and/or through community request) to make the material available'
          when 'in_progress'
            'Work on the material is in progress'
          when 'completed'
            'Reached minimum requirements of available materials and this is enough for now'
          when 'further_needs_expressed'
            'Reached minimum requirements of available materials and the community has expressed more are needed'
          when 'further_work_in_progress'
            'Reached minimum requirements of available materials and more are being made'
          else
            ''
        end
      else
        ''
    end
  end

end
