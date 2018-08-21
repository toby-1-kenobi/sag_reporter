class AddCreatedByToMinistryOutputs < ActiveRecord::Migration
  def change
    add_reference :ministry_outputs, :creator, index: true, null: false
    add_foreign_key :ministry_outputs, :users, column: :creator_id
  end
end
