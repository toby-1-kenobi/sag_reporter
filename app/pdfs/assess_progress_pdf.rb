require 'open-uri'

class AssessProgressPdf < Prawn::Document

  def initialize(state_language, months, user, reports, latest_progress)
    super(page_layout: :portrait)
    @state_language = state_language
    @months = months
    @user = user
    @reports = reports
    @latest_progress = latest_progress
    font_families.update("NotoSerif" => {
        :normal => "#{Rails.root}/app/assets/fonts/NotoSerif-Regular.ttf",
        :bold => "#{Rails.root}/app/assets/fonts/NotoSerif-Bold.ttf",
        :italic => "#{Rails.root}/app/assets/fonts/NotoSerif-Italic.ttf",
        :bold_italic => "#{Rails.root}/app/assets/fonts/NotoSerif-BoldItalic.ttf"
    })
    font_families.update("NotoSerifDevanagari" => {
        :normal => "#{Rails.root}/app/assets/fonts/NotoSerifDevanagari-Regular.ttf",
        :bold => "#{Rails.root}/app/assets/fonts/NotoSerifDevanagari-Bold.ttf"
    })
    font_families.update("NotoSerifBengali" => {
        :normal => "#{Rails.root}/app/assets/fonts/NotoSerifBengali-Regular.ttf",
        :bold => "#{Rails.root}/app/assets/fonts/NotoSerifBengali-Bold.ttf"
    })
    font('NotoSerif')
    fallback_fonts(['NotoSerifDevanagari', 'NotoSerifBengali'])
    header
    content
  end

  def header
    text "Assess the outcome progress for #{@state_language.language_name} in #{@state_language.state_name} over the last #{@months} months", size: 18, style: :bold
    text "Last assessment was in #{@state_language.progress_last_set.strftime('%B %Y')}"
  end

  def content
    Topic.all.order(:number).each do |outcome_area|
      pad_top(10) { text outcome_area.name, size: 16, style: :bold }
      outcome_area.progress_markers.active.order(:number).each do |pm|
        bounding_box([0, cursor], width: 500) do
          pad(5) { text "#{pm.number}. #{pm.description_for(@user)}" }
          stroke_bounds
        end
        if @latest_progress[pm]
          pad(5) { text "progress last set to #{@latest_progress[pm]} (#{ProgressMarker.spread_text[@latest_progress[pm]]})" }
        else
          pad(5) { text "no previous progress recorded" }
        end
        if @reports[pm] and @reports[pm].any?
          print_reports(@reports[pm])
        else
          pad(5) { text 'no impact reports for this progress marker' }
        end
      end
    end
  end

  def print_reports(reports)
    reports.each do |report|
      pad_top(5) { text report.report_date.to_s, style: :bold }
      text report.content
      report.pictures.each do |picture|
        if Rails.env.production?
          begin
            image open(picture.ref_url), fit: [500,500] if picture.ref?
          rescue OpenURI::HTTPError e
            text 'image missing'
          end
        else
          image "#{Rails.root}/public#{picture.ref_url}", fit: [500,500] if picture.ref?
        end
      end
    end
  end

end