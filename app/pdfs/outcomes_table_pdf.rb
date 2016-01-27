class OutcomesTablePdf < Prawn::Document

  def initialize(outcome_areas, language, geo_state)
    super(page_layout: :landscape)
    @outcome_areas = outcome_areas
    @language = language
    @geo_state = geo_state
    header
    table_content
  end

  def header
  	text "#{@language.name}, #{@geo_state.name}", size: 20, style: :bold
  end

  def table_content
  	table @language.outcome_table_data(@outcome_areas, @geo_state) do
      row(0).font_style = :bold
      self.header = true
  	end
  end

end