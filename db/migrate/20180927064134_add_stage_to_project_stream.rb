class AddStageToProjectStream < ActiveRecord::Migration
  def change
    add_column :project_streams, :stage, :integer, null: false, default: 0
  end
end
