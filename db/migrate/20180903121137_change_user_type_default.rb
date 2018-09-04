class ChangeUserTypeDefault < ActiveRecord::Migration
  def change
    change_column_default :users, :user_type, from: nil, to: 1
  end
end
