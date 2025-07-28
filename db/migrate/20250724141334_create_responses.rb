class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.text :body, null: false
      t.references :user, null: false, foreign_key: true
      t.references :parent, polymorphic: true, null: false
      t.boolean :is_accepted
      t.references :tenant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
