class CreateMinistryWorkers < ActiveRecord::Migration
  def change
    create_table :ministry_workers do |t|
      t.references :ministry, index: true, foreign_key: true, null: false
      t.references :worker, index: true, null: false

      t.timestamps null: false
    end
    add_foreign_key :ministry_workers, :users, column: :worker_id
    add_index :ministry_workers, [:ministry_id, :worker_id], unique: true, name: 'index_ministry_worker'
  end
end
