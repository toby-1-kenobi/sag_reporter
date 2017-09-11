
class OutcomesTablePdf < Prawn::Document
  include ColoursHelper

  def initialize(state_language, user)
    super(page_layout: :landscape)
    @state_language = state_language
    @table_data = @state_language.outcome_table_data(user)
    header
    table_content
    line_chart
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

  def line_chart
    if @table_data
      xaxis_labels = @table_data['content'].values.first.keys
      series = []
      colours = []
      @table_data['content'].each do |oa_name, data|
        series << Prawn::Graph::Series.new(data.values, title: oa_name, type: :line)
        oa = Topic.find_by_name(oa_name)
        # store the hex of the colour of the outcome area for the line colour
        # dropping the hash off the front
        colours << materialize_colours_hex[oa.colour][1..-1]
      end
      # Overall score with a dark grey line
      series << Prawn::Graph::Series.new(@table_data['Totals'].values, title: 'Overall score', type: :line)
      colours << '707070'
      theme = Prawn::Graph::Theme.new(series: colours)
      graph series, xaxis_labels: xaxis_labels, at: [15,300], height: 280, width: 700, theme: theme
    end
  end

  # Take table data made as hashes and
  # convert to an array that prawn likes
  # values are rounded to integers along the way
  def table_to_array(table_data)
    array_data = Array.new
    # months are the table headers
    headers = table_data['content'].values.first.keys
    # first column header
    headers.unshift('Outcome Area')
    array_data.push(headers)
    table_data['content'].each do |row_name, row|
      row.each do |date, score|
        row[date] = score.round
      end
      array_data.push(row.values.unshift(row_name))
    end
    table_data['Totals'].each do |date, score|
      table_data['Totals'][date] = score.round
    end
    array_data.push(table_data['Totals'].values.unshift('Overall Score'))
    return array_data
  end

end