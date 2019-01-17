class AddPseudonymToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :pseudonym, :string, null: true
  end
end
