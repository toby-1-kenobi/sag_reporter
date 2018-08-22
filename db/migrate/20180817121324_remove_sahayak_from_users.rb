class RemoveSahayakFromUsers < ActiveRecord::Migration
  def up
    remove_reference :users, :sahayak
  end
  def down
    add_reference :users, :sahayak, index: true, null: true
    add_foreign_key :users, :users, column: :sahayak_id
  end
end
