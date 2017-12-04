class CreateProgressMarkers < ActiveRecord::Migration
  def change
    create_table :progress_markers do |t|
      t.string :name
      t.text :description
      t.belongs_to :topic, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
