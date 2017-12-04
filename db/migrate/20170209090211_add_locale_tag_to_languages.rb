class AddLocaleTagToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :locale_tag, :string, null: true
  end
end
