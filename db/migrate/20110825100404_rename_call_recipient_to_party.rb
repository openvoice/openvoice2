class RenameCallRecipientToParty < ActiveRecord::Migration
  def change
    rename_column :calls, :recipient_address, :party_address
  end
end
