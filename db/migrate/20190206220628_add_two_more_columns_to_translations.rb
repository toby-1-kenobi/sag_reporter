class AddTwoMoreColumnsToTranslations < ActiveRecord::Migration
  def change
    add_column :translations, :interpolations, :string
    add_column :translations, :is_proc, :boolean, null: false, :default => false
  end
end
