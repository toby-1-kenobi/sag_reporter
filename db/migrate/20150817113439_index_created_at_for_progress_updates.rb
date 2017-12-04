class IndexCreatedAtForProgressUpdates < ActiveRecord::Migration
  def change
  	add_index :progress_updates, :created_at
  end
end
