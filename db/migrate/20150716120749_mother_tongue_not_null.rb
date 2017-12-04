class MotherTongueNotNull < ActiveRecord::Migration
  def change
  	change_column_null(:users, :mother_tongue_id, false, "746783232" )
  end
end
