class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :prefix_id

      t.timestamps
    end

    add_index :users, :prefix_id
  end
end
