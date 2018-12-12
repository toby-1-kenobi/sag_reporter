class QuarterlyReportPdf < Prawn::Document

  def initialize(project, sub_project, quarter, view_context)
    super(page_layout: :portrait, top_margin: 60)
    @view = view_context
    header("#{quarter} (#{@view.pretty_quarter(quarter, true)})", sub_project ? sub_project.name : project.name, "printed #{Date.today.strftime('%Y-%m-%d')}")
    state_languages = project.state_languages.order(:id)
    if sub_project
      state_languages = state_languages.to_a.select{ |sl| sub_project.language_streams.exists?(state_language_id: sl.id) }
    end
    multi_state = project.geo_states.uniq.count > 1
    text "Quarterly Report for #{project.name}, #{quarter[0..3]} quarter #{quarter[-1]}", size: 20
    text "(Sub-project #{sub_project.name})", size: 16 if sub_project
    move_down 5
    text @view.pretty_quarter(quarter), size: 16
    move_down 15
    first_language_loop = true
    state_languages.each do |state_language|
      start_new_page unless first_language_loop
      text state_language.name(multi_state), size: 16
      streams = project.ministries.order(:code)
      if sub_project
        streams = streams.to_a.select {|s| sub_project.language_streams.exists?(state_language_id: state_language.id, ministry_id: s.id)}
      end
      streams.each do |stream|
        move_down 3
        text "<b>#{stream.name.en}</b>", inline_format: true

        values_table = []
        stream.deliverables.order(:number).each do |deliverable|
          unless deliverable.disabled?
            target = QuarterlyTarget.find_by(state_language: state_language, deliverable: deliverable, quarter: quarter)
            target_value = target ? target.value : '?'
            actual = @view.quarterly_actual(state_language.id, deliverable, quarter, project, sub_project)
            values_table << [deliverable.short_form.en, target_value, actual]
          end
        end

        if sub_project
          sp_id = sub_project.id
        else
          sp_ids = project.language_streams.where(state_language: state_language, ministry: stream).pluck(:sub_project_id).uniq
          sp_id = sp_ids.length == 1 ? sp_ids[0] : nil
        end
        quarterly_evaluation = QuarterlyEvaluation.find_by(
            project: project,
            sub_project_id: sp_id,
            state_language: state_language,
            ministry: stream,
            quarter: quarter
        )

        if quarterly_evaluation
          quarterly_report(values_table, quarterly_evaluation)
        else
          table values_table, width: 290
        end
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

  def quarterly_report(values_table, quarterly_evaluation)

    narrative_questions = []
    (1..4).each do |i|
      answer = quarterly_evaluation.send("question_#{i}")
      if answer.present?
        narrative_questions << [I18n.t("narrative_questions.q#{i}_html")]
        narrative_questions << [answer]
      end
    end
    if narrative_questions.any?
      middle = make_table narrative_questions, cell_style: {borders: [], inline_format: true}, width: 200, row_colors: ["F0F0F0", "FFFFCC"]
      left_width, right_width = [180, 160]
    else
      middle = ''
      left_width, right_width = [290, 240]
    end

    left = make_table values_table, width: left_width

    report = []
    if quarterly_evaluation.report.present?
      report << [quarterly_evaluation.report.content]
      quarterly_evaluation.report.pictures.each do |picture|
        if Rails.env.production?
          begin
            report << [{ image: open(picture.ref_url), image_width: right_width }] if picture.ref?
          rescue OpenURI::HTTPError => e
            report << ['image missing']
          end
        else
          report << [{ image: "#{Rails.root}/public#{picture.ref_url}", image_width: right_width }] if picture.ref?
        end
      end
    end
    report << ["Manager assessment: #{I18n.t("progress.#{quarterly_evaluation.progress}", default: quarterly_evaluation.progress.humanize)}"] if quarterly_evaluation.progress.present?
    if quarterly_evaluation.approved?
      report << (File.file?(@view.image_url('approved.png')) ? [{image: @view.image_url('approved.png'), image_width: 150}] : ['Quarterly report approved by manager.'])
    else
      report << ['pending approval by manager']
    end
    right = make_table report, cell_style: {borders: []}, width: right_width

    table [[left, middle, right]], cell_style: {borders: []}
  end

end