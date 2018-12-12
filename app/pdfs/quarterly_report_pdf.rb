class QuarterlyReportPdf < Prawn::Document

  def initialize(project, sub_project, quarter, view_context)
    super(page_layout: :portrait, top_margin: 60)
    @view = view_context
    header("#{quarter} (#{@view.pretty_quarter(quarter, true)})", sub_project ? sub_project.name : project.name, "printed #{Date.today.strftime('%Y-%m-%d')}")
    if sub_project
      state_languages = sub_project.quarterly_evaluations.group_by(&:state_language)
    else
      state_languages = project.quarterly_evaluations.group_by(&:state_language)
    end
    multi_state = project.geo_states.uniq.count > 1
    text "Quarterly Report for #{project.name}, #{quarter[0..3]} quarter #{quarter[-1]}", size: 20
    text "(Sub-project #{sub_project.name})", size: 16 if sub_project
    move_down 5
    text @view.pretty_quarter(quarter), size: 16
    move_down 15
    first_language_loop = true
    state_languages.each do |state_language, evaluations|
      start_new_page unless first_language_loop
      text state_language.name(multi_state), size: 16
      evaluations.each do |quarterly_evaluation|
        move_down 3
        text "<b>#{quarterly_evaluation.ministry.name.en}</b>", inline_format: true
        quarterly_report(quarterly_evaluation)
      end
      first_language_loop = false
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

    values_table = []
    quarterly_evaluation.ministry.deliverables.order(:number).each do |deliverable|
      unless deliverable.disabled?
        target = QuarterlyTarget.find_by(state_language: quarterly_evaluation.state_language, deliverable: deliverable, quarter: quarterly_evaluation.quarter)
        target_value = target ? target.value : '?'
        actual = @view.quarterly_actual(quarterly_evaluation.state_language_id, deliverable, quarterly_evaluation.quarter, quarterly_evaluation.project, quarterly_evaluation.sub_project)
        values_table << [deliverable.short_form.en, target_value, actual]
      end
    end
    left = make_table values_table, width: 180

    narrative_questions = []
    (1..4).each do |i|
      narrative_questions << [I18n.t("narrative_questions.q#{i}_html")]
      narrative_questions << [quarterly_evaluation.send("question_#{i}")]
    end
    middle = make_table narrative_questions, cell_style: {borders: [], inline_format: true}, width: 200, row_colors: ["F0F0F0", "FFFFCC"]

    report = []
    if quarterly_evaluation.report.present?
      report << [quarterly_evaluation.report.content]
      quarterly_evaluation.report.pictures.each do |picture|
        if Rails.env.production?
          begin
            report << [{ image: open(picture.ref_url), image_width: 160 }] if picture.ref?
          rescue OpenURI::HTTPError => e
            report << ['image missing']
          end
        else
          report << [{ image: "#{Rails.root}/public#{picture.ref_url}", image_width: 160 }] if picture.ref?
        end
      end
    end
    report << ["Manager assessment: #{I18n.t("progress.#{quarterly_evaluation.progress}", default: quarterly_evaluation.progress.humanize)}"] if quarterly_evaluation.progress.present?
    if quarterly_evaluation.approved?
      report << (File.file?(@view.image_url('approved.png')) ? [{image: @view.image_url('approved.png'), image_width: 150}] : ['Quarterly report approved by manager.'])
    else
      report << ['pending approval by manager']
    end
    Rails.logger.debug report
    right = make_table report, cell_style: {borders: []}, width: 160

    table [[left, middle, right]], cell_style: {borders: []}
  end

end