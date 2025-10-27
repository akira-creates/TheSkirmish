class Match < ApplicationRecord
  belongs_to :pool, optional: true
  belongs_to :fighter1, class_name: 'Fighter'
  belongs_to :fighter2, class_name: 'Fighter'
  belongs_to :winner, class_name: 'Fighter', optional: true

  belongs_to :fighter1_main, class_name: 'Weapon', optional: true
  belongs_to :fighter1_offhand, class_name: 'Weapon', optional: true
  belongs_to :fighter2_main, class_name: 'Weapon', optional: true
  belongs_to :fighter2_offhand, class_name: 'Weapon', optional: true

  validates :status, presence: true

  DEBUFFS = [ 'None', 'Blindfold', 'One Hand', 'Backwards', 'Kneeling', 'No Footwork' ]
  MAX_POINTS = 12
  MAX_DURATION = 180 # 3 minutes in seconds

  def complete_match(winner_id, f1_points, f2_points, match_duration)
    update(
      winner_id: winner_id,
      fighter1_points: f1_points,
      fighter2_points: f2_points,
      duration: match_duration,
      status: 'completed'
    )
  end

  def weapons_selected?
    fighter1_main_id.present? && fighter2_main_id.present?
  end
end
