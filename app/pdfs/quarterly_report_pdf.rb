class QuarterlyReportPdf < Prawn::Document
  include DatesHelper

  def initialize(project, sub_project, quarter)
    super(page_layout: :portrait)
    header("#{quarter} (#{pretty_quarter(quarter, true)})", sub_project ? sub_project.name : project.name, "printed #{Date.today.strftime('%Y-%m-%d')}")
    if sub_project
      state_languages = project.state_languages.order(:id).to_a.select{ |sl| sub_project.language_streams.exists?(state_language_id: sl.id) }
    else
      state_languages = project.state_languages.order(:id)
    end
    multi_state = project.geo_states.uniq.count > 1
    text "Quarterly Report for #{project.name}, #{quarter[0..3]} quarter #{quarter[-1]}", size: 20
    text "(Sub-project #{sub_project.name})", size: 16 if sub_project
    move_down 5
    text pretty_quarter(quarter), size: 16
    state_languages.each do |state_language|
      move_down 15
      text state_language.name(multi_state), size: 16
      if sub_project
        streams = project.ministries.order(:code).to_a.select {|s| sub_project.language_streams.exists?(state_language_id: state_language.id, ministry_id: s.id)}
      else
        streams = project.ministries.order(:code)
      end
      streams.each do |stream|
        text stream.name.en
      end
    end
  end

  def header(left, centre, right)
    repeat :all do
      bounding_box [bounds.left, bounds.top], :width  => bounds.width do
        font "Helvetica"
        text_box left
        text_box centre, :align => :center
        text right, :align => :right
        stroke_horizontal_rule
        move_down 5
      end
    end
  end

end