class DropProjectUsers < ActiveRecord::Migration
  def change
    drop_table :project_users do |t|
      t.references :project, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
