class DifferentAttribute < ApplicationRecord
  has_prefix_id :diff, attribute: :attribute_id
end
