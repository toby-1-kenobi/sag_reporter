class AddLanguageToChurchMinistries < ActiveRecord::Migration
  def change
    add_reference :church_ministries, :language, index: true, foreign_key: true, null: false
  end
end
