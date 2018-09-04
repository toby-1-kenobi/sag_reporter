class DropCluster < ActiveRecord::Migration
  def change
    remove_reference :languages, :cluster
    drop_table :clusters do |t|
      t.string name, null: false, index: true, unique: true
      t.timestamps null: false
    end
  end
end
