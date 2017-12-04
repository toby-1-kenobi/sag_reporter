class CreateProgressUpdates < ActiveRecord::Migration
  def change
    create_table :progress_updates do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :language_progress, index: true, foreign_key: true, null: false
      t.integer :progress

      t.timestamps null: false
    end
  end
end
