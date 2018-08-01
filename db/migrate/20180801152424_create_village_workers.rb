class CreateVillageWorkers < ActiveRecord::Migration
  def change
    create_table :village_workers do |t|
      t.references :worker, index: true, null: false
      t.references :village, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_foreign_key :village_workers, :users, column: :worker_id
    add_index :village_workers, [:village_id, :worker_id], unique: true, name: 'index_village_worker'
  end
end
