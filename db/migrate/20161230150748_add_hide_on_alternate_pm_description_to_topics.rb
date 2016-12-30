class AddHideOnAlternatePmDescriptionToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :hide_on_alternate_pm_description, :boolean, null: false, default: false
  end
end
