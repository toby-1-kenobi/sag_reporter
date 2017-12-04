class AddColourToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :colour, :string, null: false, default: "#FFFFFF"
  end
end
