class RemoveSahayakFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :sahayak_id
  end
end
