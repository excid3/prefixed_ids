class Team < ApplicationRecord
  has_prefix_id :team, fallback: false
end
