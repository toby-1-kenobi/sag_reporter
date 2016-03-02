class ReportSuperHasState < ActiveRecord::Migration

  def up
    puts "This migration will do nothing if ImpactReports delegates :state to Report."
    puts "are you sure you want to continue? [Y/n]"
    answer = $stdin.gets.chomp
    if answer != 'y' and answer != 'Y'
      fail "Make sure ImpactReports does not delegate :state to Report, then try again."
    end
    remove_column :planning_reports, :status
    remove_column :challenge_reports, :status
    ImpactReport.find_each do |ir|
      report = ir.report
      report.state = ir.state
      report.save!
    end
    remove_column :impact_reports, :state
  end

  def down
    puts "This migration will do nothing if ImpactReports delegates :state to Report."
    puts "are you sure you want to continue? [Y/n]"
    answer = $stdin.gets.chomp
    if answer != 'y' and answer != 'Y'
      fail "Make sure ImpactReports does not delegate :state to Report, then try again."
    end
    add_column :impact_reports, :state, :integer
    ImpactReport.find_each do |ir|
      state = ir.report.state
      state = 1 if state == "active"
      state = 0 if state == "archived"
      ir.state = state
      ir.save!
    end
    add_column :challenge_reports, :status, :integer
    add_column :planning_reports, :status, :integer
  end

end
