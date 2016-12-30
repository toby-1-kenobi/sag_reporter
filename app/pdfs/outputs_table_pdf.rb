class OutputsTablePdf < Prawn::Document

  def initialize(language, geo_state, user)
    super(page_layout: :landscape)
    @language = language
    @geo_state = geo_state
    header
    table_content(user)
  end

  def header
  	text "#{@language.name}, #{@geo_state.name}", size: 20, style: :bold
  end

  def table_content(user)
  	table @language.table_data(@geo_state, user) do
      row(0).font_style = :bold
      self.header = true
  	end
  end

end