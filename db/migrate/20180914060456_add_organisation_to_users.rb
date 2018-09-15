class AddOrganisationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :organisation, :string, null: true
  end
end
