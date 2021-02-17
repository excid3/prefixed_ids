class Account < ApplicationRecord
  has_prefix_id :acct, length: 32
end
