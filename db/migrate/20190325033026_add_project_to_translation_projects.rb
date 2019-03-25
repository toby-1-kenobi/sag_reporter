class AddProjectToTranslationProjects < ActiveRecord::Migration
  def change
    add_reference :translation_projects, :project, index: true, foreign_key: true, null: false
    reversible do |change|
      change.up do
        add_index :translation_projects, [:language_id, :project_id], unique: true, name: 'index_translation_projects_unique'
      end
      change.down do
        add_index :translation_projects, [:language_id, :name], unique: true, name: 'index_translation_projects_unique'
      end
    end
    remove_column :translation_projects, :name, :string, index: true, null: false
  end
end

