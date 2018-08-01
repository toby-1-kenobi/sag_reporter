class AddDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_last_login_dt, :date, :default => Date.today, presence: true
  end
end
