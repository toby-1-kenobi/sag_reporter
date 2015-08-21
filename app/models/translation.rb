class Translation < ActiveRecord::Base
  belongs_to :translatable
  belongs_to :language

  def self.get_string(identifier, user)
  	translatable = Translatable.find_by_identifier!(identifier)
  	unless user.interface_language then return translatable.content end
  	translation = Translation.find_or_create_by(translatable: translatable, language: user.interface_language)
  	(translation.content and not translation.content.empty?) ? translation.content : translatable.content
  end

end
