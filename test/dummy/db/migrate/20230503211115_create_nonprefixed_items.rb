class CreateNonprefixedItems < ActiveRecord::Migration[6.1]
  def change
    create_table :nonprefixed_items do |t|
      t.integer :user_id
      t.timestamps
    end
  end
end
