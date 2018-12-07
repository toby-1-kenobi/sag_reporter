class QuarterlyReportPdf < Prawn::Document
  include DatesHelper
  include StateLanguagesHelper

  def initialize(project, sub_project, quarter)
    super(page_layout: :portrait, top_margin: 60)
    header("#{quarter} (#{pretty_quarter(quarter, true)})", sub_project ? sub_project.name : project.name, "printed #{Date.today.strftime('%Y-%m-%d')}")
    if sub_project
      state_languages = sub_project.quarterly_evaluations.group_by(&:state_language)
    else
      state_languages = project.quarterly_evaluations.group_by(&:state_language)
    end
    multi_state = project.geo_states.uniq.count > 1
    text "Quarterly Report for #{project.name}, #{quarter[0..3]} quarter #{quarter[-1]}", size: 20
    text "(Sub-project #{sub_project.name})", size: 16 if sub_project
    move_down 5
    text pretty_quarter(quarter), size: 16
    state_languages.each do |state_language, evaluations|
      move_down 15
      text state_language.name(multi_state), size: 16
      evaluations.each do |quarterly_evaluation|
        move_down 3
        text "<b>#{quarterly_evaluation.ministry.name.en}</b>", inline_format: true
        quarterly_report(quarterly_evaluation)
      end
    end
  end

  def header(left, centre, right)
    repeat :all do
      bounding_box [bounds.left, bounds.top + 30], :width  => bounds.width do
        font "Helvetica"
        text_box left
        text_box centre, :align => :center
        text right, :align => :right
        stroke_horizontal_rule
      end
      move_down 10
    end
  end

  def quarterly_report(quarterly_evaluation)
    table = []
    quarterly_evaluation.ministry.deliverables.order(:number).each do |deliverable|
      unless deliverable.disabled?
        target = QuarterlyTarget.find_by(state_language: quarterly_evaluation.state_language, deliverable: deliverable, quarter: quarterly_evaluation.quarter)
        target_value = target ? target.value : '?'
        actual = quarterly_actual(quarterly_evaluation.state_language_id, deliverable, quarterly_evaluation.quarter, quarterly_evaluation.project, quarterly_evaluation.sub_project)
        table << [deliverable.short_form.en, target_value, actual]
      end
    end
    table table
  end

end