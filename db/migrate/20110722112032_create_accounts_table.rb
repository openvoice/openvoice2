class CreateAccountsTable < ActiveRecord::Migration
  def change
    create_table :accounts, :force => true do |table|
      table.string :email, :null => false
      table.string :password_digest, :null => false
    end
  end
end
