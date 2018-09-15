class CreateProjectLanguages < ActiveRecord::Migration
  def change
    create_table :project_languages do |t|
      t.references :project, index: true, foreign_key: true, null: false
      t.references :state_language, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :project_languages, [:project_id, :state_language_id], unique: true, name: 'index_project_language'
  end
end
