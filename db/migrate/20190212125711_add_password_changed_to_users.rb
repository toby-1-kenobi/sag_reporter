class AddPasswordChangedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_changed, :datetime
    User.all.each{|user| user.update password_changed: user.updated_at }
    change_column_null :users, :password_changed, false
  end
end
