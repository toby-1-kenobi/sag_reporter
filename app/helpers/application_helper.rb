module ApplicationHelper

  # Returns the full page title on a per-page basis.
  def full_title(page_title = '')
    base_title = "NBASE reporter"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def flash_values
	  flash_value = {
	  	"error" => {
	  	  icon: "mdi-alert-error",
	  	  colour: "red",
	  	  text_colour: "grey-text text-lighten-2"
	  	},
	  	"warning" => {
	  	  icon: "mdi-alert-warning",
	  	  colour: "amber",
	  	  text_colour: "grey-text text-lighten-2"
	  	},
	  	"success" => {
	  	  icon: "mdi-action-done",
	  	  colour: "green",
	  	  text_colour: "grey-text text-lighten-2"
	  	},
	  	"info" => {
	  	  icon: "mdi-action-info",
	  	  colour: "teal",
	  	  text_colour: "grey-text text-lighten-2"
	  	}
	  }
  end

end
