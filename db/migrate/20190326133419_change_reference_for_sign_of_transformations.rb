class ChangeReferenceForSignOfTransformations < ActiveRecord::Migration
  def up
    add_reference :sign_of_transformations, :marker, index: true
    add_foreign_key :sign_of_transformations, :sign_of_transformation_markers, column: 'marker_id'
    remove_reference :sign_of_transformations, :progress_marker
  end
  def down
    remove_reference :sign_of_transformations, :marker
    add_reference :sign_of_transformations, :progress_marker, index: true
  end
end
