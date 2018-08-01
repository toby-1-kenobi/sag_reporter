class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_sahayak, :boolean, default: false, null: false
    add_column :users, :training_level, :integer
    add_reference :users, :sahayak, index: true, null: true
    add_foreign_key :users, :users, column: :sahayak_id
  end
end
