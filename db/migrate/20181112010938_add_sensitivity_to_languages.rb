class AddSensitivityToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :sensitivity, :integer, index: true, null:false, default: 1
    add_column :languages, :egids, :integer, index: true, null: true
  end
end
