class RemoveInterfaceBoolFromLanguages < ActiveRecord::Migration
  def change
    remove_column :languages, :interface
  end
end
