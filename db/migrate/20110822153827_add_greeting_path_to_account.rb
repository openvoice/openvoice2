class AddGreetingPathToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :greeting_path, :string
  end
end
