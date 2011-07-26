class AddUsernameToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :username, :string
  end
end
