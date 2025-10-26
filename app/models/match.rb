class Match < ApplicationRecord
  belongs_to :pool
  belongs_to :fighter1
  belongs_to :fighter2
  belongs_to :winner
end
