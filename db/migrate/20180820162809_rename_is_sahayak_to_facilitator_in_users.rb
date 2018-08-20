class RenameIsSahayakToFacilitatorInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :is_sahayak, :facilitator
  end
end
