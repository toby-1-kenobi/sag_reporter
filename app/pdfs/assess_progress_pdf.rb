class AssessProgressPdf < Prawn::Document

  def initialize(state_language, months, user)
    super(page_layout: :portrait)
    @state_language = state_language
    @months = months
    @user = user
    header
    content
  end

  def header
    text "Assess the outcome progress for #{@state_language.language_name} in #{@state_language.state_name} over the last #{@months} months", size: 18, style: :bold
  end

  def content
    Topic.find_each do |outcome_area|
      text outcome_area.name, size: 16, style: :bold
      outcome_area.progress_markers.active.order(:number).each do |pm|
        text pm.description_for(@user)
      end
    end
  end

end