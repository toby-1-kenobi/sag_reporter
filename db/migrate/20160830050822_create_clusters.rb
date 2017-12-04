class CreateClusters < ActiveRecord::Migration
  def change
    create_table :clusters do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :clusters, :name, unique: true
  end
end
