class RemoveLanguageFromChurchMinistry < ActiveRecord::Migration
  def up
    remove_reference :church_ministries, :language
  end
  def down
    add_reference :church_ministries, :language, index: true, foreign_key: true, null: false
  end
end
