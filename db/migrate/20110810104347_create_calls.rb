class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.string :recipient_address
      t.integer :endpoint_id

      t.timestamps
    end
  end
end
