# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_17_022009) do
  create_table "accounts", force: :cascade do |t|
    t.string "prefix_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["prefix_id"], name: "index_accounts_on_prefix_id"
  end

  create_table "different_attributes", force: :cascade do |t|
    t.string "attribute_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["attribute_id"], name: "index_different_attributes_on_attribute_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "prefix_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["prefix_id"], name: "index_users_on_prefix_id"
  end
end
