class RenameCategoryToMediumInMtResources < ActiveRecord::Migration
  def change
    rename_column :mt_resources, :category, :medium
  end
end
