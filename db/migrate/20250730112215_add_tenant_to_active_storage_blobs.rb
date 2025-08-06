class AddTenantToActiveStorageBlobs < ActiveRecord::Migration[8.0]
  def change
    add_reference :active_storage_blobs, :tenant, null: true, foreign_key: true
  end
end
