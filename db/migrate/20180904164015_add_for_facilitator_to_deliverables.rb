class AddForFacilitatorToDeliverables < ActiveRecord::Migration
  def change
    add_column :deliverables, :for_facilitator, :boolean, null: false, default: false, index: true
  end
end
