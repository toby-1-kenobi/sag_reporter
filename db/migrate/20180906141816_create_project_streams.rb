class CreateProjectStreams < ActiveRecord::Migration
  def change
    create_table :project_streams do |t|
      t.references :project, index: true, foreign_key: true, null: false
      t.references :ministry, index: true, foreign_key: true, null: false
      t.references :supervisor, index: true, null: false

      t.timestamps null: false
    end
    add_foreign_key :project_streams, :users, column: :supervisor_id
    add_index :project_streams, [:project_id, :ministry_id], unique: true, name: 'index_project_ministry'
  end
end
