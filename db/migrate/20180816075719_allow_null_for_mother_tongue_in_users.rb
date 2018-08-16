class AllowNullForMotherTongueInUsers < ActiveRecord::Migration
  def change
    change_column_null :users, :mother_tongue_id, true
  end
end
