class AddResetPasswordTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reset_password_token, :string, null: true
  end
end
