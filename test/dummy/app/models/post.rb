class Post < ApplicationRecord
  has_prefix_id :post
  belongs_to :user
end
