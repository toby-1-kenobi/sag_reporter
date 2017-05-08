class CreateFinishLineMarkers < ActiveRecord::Migration
  def change
    create_table :finish_line_markers do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :number, null: false

      t.timestamps null: false
    end
  end
end
