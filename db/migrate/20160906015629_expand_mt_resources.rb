class ExpandMtResources < ActiveRecord::Migration
  def change
    add_column :mt_resources, :status, :integer, null: false, default: 0
    add_column :mt_resources, :publish_year, :integer
    add_column :mt_resources, :url, :string
    add_column :mt_resources, :how_to_access, :text
  end
end
