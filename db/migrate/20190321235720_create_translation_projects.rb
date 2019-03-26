class CreateTranslationProjects < ActiveRecord::Migration
  def change
    create_table :translation_projects do |t|
      t.references :language, index: true, foreign_key: true
      t.string :name, null: false, index: true
      t.text :office_location
      t.text :survey_findings
      t.text :orthography_notes
      t.string :publisher
      t.string :copyright

      t.timestamps null: false
    end
    add_index :translation_projects, [:language_id, :name], unique: true, name: 'index_translation_projects_unique'
  end
end
