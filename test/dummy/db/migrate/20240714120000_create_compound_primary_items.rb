if PrefixedIds::Test.rails71_and_up?
  class CreateCompoundPrimaryItems < ActiveRecord::Migration[6.1]
    def change
      create_table :compound_primary_items, primary_key: %i[id user_id] do |t|
        t.integer :id
        t.integer :user_id
        t.timestamps
      end
    end
  end
end
