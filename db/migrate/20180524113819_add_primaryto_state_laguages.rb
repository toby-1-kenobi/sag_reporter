class AddPrimarytoStateLaguages < ActiveRecord::Migration
  def change
    add_column :state_languages, 'primary', :boolean, null: false, default: false
  end
end
