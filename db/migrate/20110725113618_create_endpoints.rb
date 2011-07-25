class CreateEndpoints < ActiveRecord::Migration
  def change
    create_table :endpoints do |t|
      t.string :address
      t.integer :account_id

      t.timestamps
    end
  end
end
