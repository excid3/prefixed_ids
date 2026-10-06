class Post < ApplicationRecord
  has_prefix_id :post, override_exists: false
  belongs_to :user
  belongs_to :nonprefixed_item, optional: true
end
