class CreateSubProjects < ActiveRecord::Migration
  def change
    create_table :sub_projects do |t|
      t.string :name, index: true, null: false
      t.references :project, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :sub_projects, [:name, :project_id], unique: true
  end
end
