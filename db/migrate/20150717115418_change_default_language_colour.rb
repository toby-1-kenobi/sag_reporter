class ChangeDefaultLanguageColour < ActiveRecord::Migration
  def change
  	change_column_default :languages, :colour, "white"
  end
end
