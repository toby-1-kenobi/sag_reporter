class CreateSignOfTransformation < ActiveRecord::Migration
  def change
    create_table :sign_of_transformations do |t|
      t.references :church_ministry, index: true, foreign_key: true, null: false
      t.string :month, null: false
      t.references :progress_marker, index: true, foreign_key: true
      t.string :other

      t.timestamps null: false
    end
  end
end
