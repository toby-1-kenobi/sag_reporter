module ColoursHelper

  def materialize_colours
  	[
  		"red",
  		"pink",
  		"purple",
  		"deep-purple",
  		"indigo",
  		"blue",
  		"light-blue",
  		"cyan",
  		"teal",
  		"green",
  		"light-green",
  		"lime",
  		"yellow",
  		"amber",
  		"orange",
  		"deep-orange",
  		"brown",
  		"grey",
  		"blue-grey",
  		"black",
  		"white"
  	]
  end

  def colour_class(colour_str)
    "#{colour_str} #{colour_class_text(colour_str)}"
  end

  def colour_class_text(colour_str)
    colour_str.include?('darken') || colour_str == 'black' ? 'white-text' : 'black-text'
  end

end