class AddFunderInterestToDeliverable < ActiveRecord::Migration
  def change
    add_column :deliverables, :funder_interest, :boolean, default: true, null: false
  end
end
