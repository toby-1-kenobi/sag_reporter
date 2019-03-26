class CreateSignOfTransformationMarker < ActiveRecord::Migration
  def change
    create_table :sign_of_transformation_markers do |t|
      t.references :name, index: true, null: false
      t.references :ministry, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    add_foreign_key :sign_of_transformation_markers, :translation_codes, column: 'name_id'
  end
end
