class ChangeNullForNameInLanguages < ActiveRecord::Migration
  def change
    change_column_null :languages, :name, false
  end
end
