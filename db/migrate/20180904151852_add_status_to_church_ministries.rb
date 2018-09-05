class AddStatusToChurchMinistries < ActiveRecord::Migration
  def change
    add_column :church_ministries, :status, :integer, null: false, default: 0, index: true
  end
end
