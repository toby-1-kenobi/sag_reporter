class OutputsTablePdf < Prawn::Document

  def initialize(language)
    super(page_layout: :landscape)
    @language = language
    header
    table_content
  end

  def header
  	text @language.name, size: 20, style: :bold
  end

  def table_content
  	table @language.table_data do
      row(0).font_style = :bold
      self.header = true
  	end
  end

end