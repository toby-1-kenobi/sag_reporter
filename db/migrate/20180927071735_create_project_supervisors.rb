class CreateProjectSupervisors < ActiveRecord::Migration
  def change
    create_table :project_supervisors do |t|
      t.references :project, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :role, null: false

      t.timestamps null: false
    end
    add_index :project_supervisors, [:project_id, :user_id, :role], unique: true, name: 'index_project_supervisor_role'
  end
end
