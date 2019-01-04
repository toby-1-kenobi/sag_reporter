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
      text state_language.name(multi_state), size: 18
      streams = project.ministries.order(:code)
      if sub_project
        streams = streams.to_a.select {|s| sub_project.language_streams.exists?(state_language_id: state_language.id, ministry_id: s.id)}
      end
      streams.each do |stream|

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

        move_down 15
        if quarterly_evaluation and quarterly_evaluation.progress.present?
          fill_color progress_colour(quarterly_evaluation)
          fill_rectangle [0, cursor + 5], bounds.width, 40
          fill_color "000000"
        end
        indent(10){ text "<b>#{stream.name.en}</b> in #{state_language.language_name}", inline_format: true, size: 16 }
        if quarterly_evaluation
          text "progress this quarter: #{quarterly_evaluation.progress.humanize}", align: :center if quarterly_evaluation.progress.present?

          if quarterly_evaluation.approved?
            if File.file?(@view.image_url('approved.png'))
              image @view.image_url('approved.png'), width: 150, align: :right
            else
              text 'Quarterly report approved by manager.', align: :right
            end
          else
            text 'pending approval by manager', align: :right
          end
        end

        values_table = []
        values_table << ['Deliverable', 'Target', 'Actual']
        stream.deliverables.order(:number).each do |deliverable|
          unless deliverable.disabled?
            target = QuarterlyTarget.find_by(state_language: state_language, deliverable: deliverable, quarter: quarter)
            target_value = target ? target.value : '?'
            actual = @view.quarterly_actual(state_language.id, deliverable, quarter, project, sub_project)
            values_table << [deliverable.short_form.en, target_value, actual]
          end
        end

        move_down 5
        text 'Measureables', size: 14
        table values_table, width: bounds.width

        church_table = partnering_churches(state_language.id, stream.id)
        if church_table.any?
          move_down 10
          text 'Partnering churches', size: 14
          table church_table, cell_style: {borders: []}, width: bounds.width
        end

        if quarterly_evaluation
          move_down 10
          narrative_questions(quarterly_evaluation)
          if quarterly_evaluation.report.present?
            move_down 10
            report(quarterly_evaluation)
          end
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

  def progress_colour(quarterly_evaluation)
    case quarterly_evaluation.progress
    when 'no_progress'
      "7B68EE"
    when 'poor'
      "FF0000"
    when 'fair'
      "FFFF00"
    when 'good'
      "98FB98"
    when 'excellent'
      "00FF00"
    else
      "FFFFFF"
    end
  end

  def partnering_churches(state_language_id, stream_id)
    church_teams = ChurchTeam.joins(:church_ministries).where(state_language_id: state_language_id, church_ministries: {ministry_id: stream_id, status: 0}).uniq
    churches_table = []
    church_teams.each{ |ct| churches_table << [ct.full_name]}
    churches_table
  end

  def narrative_questions(quarterly_evaluation)
    narrative_questions = []
    (1..4).each do |i|
      answer = quarterly_evaluation.send("question_#{i}")
      if answer.present?
        narrative_questions << [I18n.t("narrative_questions.q#{i}_html")]
        narrative_questions << [answer]
      end
    end
    if narrative_questions.any?
      table narrative_questions, cell_style: {borders: [], inline_format: true}, row_colors: ["F0F0F0", "FFFFCC"], width: bounds.width
    end
  end

  def report(quarterly_evaluation)
    report = []
    report << [quarterly_evaluation.report.content]
    quarterly_evaluation.report.pictures.each do |picture|
      if Rails.env.production?
        begin
          report << [{ image: open(picture.ref_url), image_width: bounds.width }] if picture.ref?
        rescue OpenURI::HTTPError => e
          report << ['image missing']
        end
      else
        report << [{ image: "#{Rails.root}/public#{picture.ref_url}", image_width: bounds.width }] if picture.ref?
      end
    end
    text 'Sample impact story', size: 14
    table report, cell_style: {borders: []}, width: bounds.width
  end

end