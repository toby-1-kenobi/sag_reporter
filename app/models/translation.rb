class Translation < ActiveRecord::Base
  belongs_to :language
  belongs_to :translation_code

  def self.get_string(identifier, user)
  	translatable = Translatable.find_by_identifier!(identifier)
  	unless user.interface_language then return translatable.content end
  	translation = Translation.find_or_create_by(translatable: translatable, language: user.interface_language)
  	(translation.content and not translation.content.empty?) ? translation.content : translatable.content
  end

  def deliverable
    Deliverable.where("short_form_id = ? OR plan_form_id = ? OR result_form_id = ?",
                      translation_code_id, translation_code_id, translation_code_id).first
  end

  def ministry
    Ministry.where("name_id = ? OR short_form_id = ?", translation_code_id, translation_code_id).first
  end

  def connected_entry
    ministry || deliverable
  end

  def self.connected_entries(value)
    all_values = where("content like '%#{value}%'")
    if all_values.size > 1
      all_values.map &:connected_entry
    else
      all_values.first.connected_entry
    end
  end

end
