class AddAccessFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :trusted, :boolean, null: false, default: false
    add_column :users, :national, :boolean, null: false, default: false
    add_column :users, :curator, :boolean, null: false, default: false
    add_column :users, :admin, :boolean, null: false, default: false
    add_column :users, :national_curator, :boolean, null: false, default: false
  end
end
