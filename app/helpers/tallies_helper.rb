module TalliesHelper

  # Take graph data - a hash with
  # language names as keys,
  # ActiveRecord set of tally_updates as values
  # and process it to be used as parameter for chartkick functions

  def non_cumulative_data (graph_data)
  	graph_data.map{ |lang_name, updates|
	{
		name: lang_name,
		data: updates.group_by_month("tally_updates.created_at").sum(:amount)
	} }
  end

  def cumulative_data (graph_data)
  	graph_data.map{ |lang_name, updates|
	  sum = 0
	  {
		name: lang_name,
		data: updates.group_by_month("tally_updates.created_at").order("month asc").sum(:amount).map { |x,y| { x => (sum += y)} }.reduce({}, :merge)
	  } }
  end

end
