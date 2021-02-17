class Account < ApplicationRecord
  has_prefix_id :acct, minimum_length: 32, override_find: false, override_param: false
end
