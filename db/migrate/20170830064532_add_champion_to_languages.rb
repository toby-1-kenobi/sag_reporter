class AddChampionToLanguages < ActiveRecord::Migration
  def change
    add_reference :languages, :champion, index: true, null: true, references: :users
    add_foreign_key :languages, :users, column: :champion_id
  end
end
