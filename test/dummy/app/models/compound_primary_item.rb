class CompoundPrimaryItem < ApplicationRecord
  self.primary_key = [ :id, :user_id ]

  has_prefix_id :compound, minimum_length: 32, override_find: false, override_param: false, salt: "abcd"

  belongs_to :user
end
