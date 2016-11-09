class ReportSuperHasState < ActiveRecord::Migration

  def up
    remove_column :planning_reports, :status
    remove_column :challenge_reports, :status
    remove_column :impact_reports, :state
  end

  def down
    add_column :impact_reports, :state, :integer
    add_column :challenge_reports, :status, :integer
    add_column :planning_reports, :status, :integer
  end

end
