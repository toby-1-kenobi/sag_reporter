class LanguageNotDirectlyInProject < ActiveRecord::Migration
  def up
    remove_reference :languages, :project
  end
  def down
    add_reference :languages, :project, index: true, null: true
    add_foreign_key :languages, :projects
  end
end
