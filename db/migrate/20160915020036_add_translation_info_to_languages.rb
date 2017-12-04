class AddTranslationInfoToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :translation_info, :text
  end
end
