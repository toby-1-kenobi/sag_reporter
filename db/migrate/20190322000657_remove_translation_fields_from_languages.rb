class RemoveTranslationFieldsFromLanguages < ActiveRecord::Migration
  def change
    remove_column :languages, :translation_office_location, :text
    remove_column :languages, :survey_findings, :text
    remove_column :languages, :translation_orthography, :text
    remove_column :languages, :translation_publisher, :string
    remove_column :languages, :translation_copyright, :string
  end
end
