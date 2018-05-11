class AddFlagsToUser < ActiveRecord::Migration
  def change
    add_column :users, :lci_board_member, :boolean, null: false, default: false
    add_column :users, :lci_agency_leader, :boolean, null: false, default: false
  end
end
