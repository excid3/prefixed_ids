class User < ApplicationRecord
  has_prefix_id :user
  has_many :accounts
  has_many :posts
  has_many :no_prefix_id_items
end
