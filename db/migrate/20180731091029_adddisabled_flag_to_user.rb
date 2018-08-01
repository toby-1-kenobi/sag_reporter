class AdddisabledFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_disabled, :boolean, default: false, presence: true
  end
end
