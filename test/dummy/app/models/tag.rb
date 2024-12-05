class Tag < ApplicationRecord
  has_prefix_id :tag

  belongs_to :taggable, polymorphic: true
end
