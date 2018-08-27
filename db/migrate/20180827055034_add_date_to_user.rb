class AddDateToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :password_change_date, :date
    User.all.each do |us|
      us.update_attribute(:password_change_date, us.created_at)
    end
  end

  def self.down

  end
end
