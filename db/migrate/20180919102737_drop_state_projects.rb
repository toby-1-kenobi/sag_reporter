class DropStateProjects < ActiveRecord::Migration
  def up
    drop_table :state_projects
  end
  def down
    create_table :state_projects do |t|
      t.references :project, index: true, foreign_key: true, null: false
      t.references :geo_state, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :state_projects, [:project_id, :geo_state_id], unique: true, name: 'state_projects_index'
  end
end
