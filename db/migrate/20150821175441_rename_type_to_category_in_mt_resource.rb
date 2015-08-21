class RenameTypeToCategoryInMtResource < ActiveRecord::Migration
  def change
    rename_column :mt_resources, :type, :category
  end
end
