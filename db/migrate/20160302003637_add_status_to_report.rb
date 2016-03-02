class AddStatusToReport < ActiveRecord::Migration

  def up
    add_column :reports, :status, :integer, null: false, default: 0
    Report.find_each do |report|
      state = report.state
      if state == "archived" or state == 0
        report.status = 1
      else
        report.status = 0
      end
      report.save!
    end
    remove_column :reports, :state
  end

  def down
    add_column :reports, :state, :integer, null: false, default: 1
    Report.find_each do |report|
      status = report.status
      if status == "archived" or status == 1
        report.state = 0
      else
        report.state = 1
      end
      report.save!
    end
    remove_column :reports, :status
  end

end
