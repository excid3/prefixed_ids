class InvalidLength < ApplicationRecord
  has_prefix_id :il, length: 5
end
