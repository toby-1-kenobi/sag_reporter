class AddChurchToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :church, :boolean, default: false, null: false, index: true
  end
end
