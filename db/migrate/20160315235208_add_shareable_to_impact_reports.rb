class AddShareableToImpactReports < ActiveRecord::Migration
  def change
    add_column :impact_reports, :shareable, :boolean, null: false, default: false
  end
end
