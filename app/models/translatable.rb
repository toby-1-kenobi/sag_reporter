class Translatable < ActiveRecord::Base
	
	has_many :translations

	def translation_for(user)
	  translation = translations.select{ |t| t.language == user.interface_language }.first
	  (translation and not translation.content.empty?) ? translation.content : content
	end
end
