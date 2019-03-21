module ApplicationHelper

  # Returns the full page title on a per-page basis.
  def full_title(page_title = '')
    base_title = "LCI App"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def flash_values
	  flash_value = {
	  	"error" => {
	  	  icon: "error",
	  	  colour: "red",
	  	  text_colour: "grey-text text-lighten-2"
	  	},
	  	"warning" => {
	  	  icon: "warning",
	  	  colour: "amber",
	  	  text_colour: "grey-text text-lighten-2"
	  	},
	  	"success" => {
	  	  icon: "done",
	  	  colour: "green",
	  	  text_colour: "grey-text text-lighten-2"
	  	},
	  	"info" => {
	  	  icon: "info",
	  	  colour: "teal",
	  	  text_colour: "grey-text text-lighten-2"
	  	}
	  }
	end

	def tab_names
    {
        progress: 'Finish Line Status',
        zones: 'Zones',
        states: 'States',
        languages: 'Languages',
				translation: 'Translation',
				projects: @dashboard_type == :nation ? 'Projects' : 'My Projects',
				projects_overview: 'Projects Overview',
        organisations: 'Agencies',
        reports: 'Impact Stories',
        board: 'All Access Report',
				details: 'Details'
    }
  end

end
