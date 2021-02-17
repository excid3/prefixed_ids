class CreateDifferentAttributes < ActiveRecord::Migration[6.1]
  def change
    create_table :different_attributes do |t|
      t.string :attribute_id

      t.timestamps
    end

    add_index :different_attributes, :attribute_id
  end
end
