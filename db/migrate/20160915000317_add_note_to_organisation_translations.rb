class AddNoteToOrganisationTranslations < ActiveRecord::Migration
  def change
    add_column :organisation_translations, :note, :text
  end
end
