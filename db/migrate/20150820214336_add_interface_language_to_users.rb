class AddInterfaceLanguageToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :interface_language, index: true
    add_foreign_key :users, :languages, column: :interface_language_id
  end
end
