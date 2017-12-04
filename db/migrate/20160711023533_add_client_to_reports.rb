class AddClientToReports < ActiveRecord::Migration
  def change
    add_column :reports, :client, :string, null: false, default: 'LCR'
    add_column :reports, :version, :string, null: false, default: 'unknown'
  end
end
