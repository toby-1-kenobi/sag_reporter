class AddInterfaceToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :interface, :bool, default: false
  end
end
