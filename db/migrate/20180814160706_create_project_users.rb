class CreateProjectUsers < ActiveRecord::Migration
  def change
    create_table :project_users do |t|
      t.references :project, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_index :project_users, [:project_id, :user_id], unique: true, name: 'index_project_user'
  end
end
