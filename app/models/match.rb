class Match < ApplicationRecord
  belongs_to :pool
  belongs_to :fighter1
  belongs_to :fighter2
  belongs_to :winner

  validates :status, presence: true

  WEAPONS = [ 'Longsword', 'Sword & Buckler', 'Rapier', 'Saber', 'Spear', 'Messer', 'Dagger' ]
  DEBUFFS = [ 'None', 'Blindfold', 'One Hand', 'Backwards', 'Kneeling' ]

  def complete_match(winner_id, f1_points, f2_points)
    update(
      winner_id: winner_id,
      fighter1_points: f1_points,
      fighter2_points: f2_points,
      status: 'completed'
    )
  end
end
