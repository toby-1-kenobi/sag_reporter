class AddColumnsToTranslations < ActiveRecord::Migration
  def change
    add_column :translations, :key, :string
    add_column :translations, :locale, :string
    add_column :translations, :value, :text
  end
end
