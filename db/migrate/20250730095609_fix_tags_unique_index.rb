class FixTagsUniqueIndex < ActiveRecord::Migration[8.0]
  def change
    # Remove the old unique index on name only
    remove_index :tags, :name

    # Add a new unique index scoped to tenant_id
    add_index :tags, [ :name, :tenant_id ], unique: true
  end
end
