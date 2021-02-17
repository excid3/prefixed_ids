class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.string :prefix_id

      t.timestamps
    end

    add_index :accounts, :prefix_id
  end
end
