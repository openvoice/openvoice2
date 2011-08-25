class AddAccountIdToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :account_id, :integer
    execute %{
      UPDATE calls
      SET account_id = endpoints.account_id
      FROM endpoints
      WHERE endpoints.id = calls.endpoint_id
    }
  end
end
