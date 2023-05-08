class CreateNoPrefixIdItems < ActiveRecord::Migration[6.1]
  def change
    create_table :no_prefix_id_items do |t|
      t.integer :user_id
      t.timestamps
    end
  end
end

