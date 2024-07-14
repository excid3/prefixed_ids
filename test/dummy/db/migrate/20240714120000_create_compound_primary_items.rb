class CreateCompoundPrimaryItems < ActiveRecord::Migration[6.1]
  def change
    create_table :compound_primary_items, primary_key: [ :id, :user_id ] do |t|
      t.integer :id
      t.integer :user_id
      t.timestamps
    end
  end
end
