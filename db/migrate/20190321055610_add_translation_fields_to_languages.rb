class AddTranslationFieldsToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :translation_office_location, :text
    add_column :languages, :survey_findings, :text
    add_column :languages, :translation_orthography, :text
    add_column :languages, :translation_publisher, :string
    add_column :languages, :translation_copyright, :string
  end
end
