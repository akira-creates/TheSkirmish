class Bracket < ApplicationRecord
  belongs_to :fighter1
  belongs_to :fighter2
  belongs_to :winner
end
