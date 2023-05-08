class NonprefixedItem < ApplicationRecord
  # Does not use prefixed IDs
  belongs_to :user
end
