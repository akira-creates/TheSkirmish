class PoolFighter < ApplicationRecord
  belongs_to :pool
  belongs_to :fighter

  validates :fighter_id, uniqueness: { scope: :pool_id }
end
