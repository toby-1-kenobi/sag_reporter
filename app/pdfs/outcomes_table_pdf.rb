class OutcomesTablePdf < Prawn::Document

  def initialize(state_language)
    super(page_layout: :landscape)
    @state_language = state_language
    @table_data = @state_language.outcome_table_data()
    header
    table_content
  end

  def header
  	text "#{@state_language.language_name}, #{@state_language.state_name}", size: 20, style: :bold
  end

  def table_content
    if @table_data  
    	table table_to_array(@table_data) do
        row(0).font_style = :bold
        self.header = true
    	end
    end
  end

  # Take table data made as hashes and
  # convert to an array that prawn likes
  def table_to_array(table_data)
    array_data = Array.new
    headers = table_data["content"].values.first.keys
    headers.unshift("Outcome Area")
    array_data.push(headers)
    table_data["content"].each do |row_name, row|
      array_data.push(row.values.unshift(row_name))
    end
    array_data.push(table_data["Totals"].values.unshift("Totals"))
    return array_data
  end

end