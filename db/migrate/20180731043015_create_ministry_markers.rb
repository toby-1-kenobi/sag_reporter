class CreateMinistryMarkers < ActiveRecord::Migration
  def change
    create_table :ministry_markers do |t|
      t.string :name, null: false, index: true
      t.text :description
      t.references :ministry, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
