class Match < ApplicationRecord
  belongs_to :pool, optional: true
  belongs_to :bracket, optional: true  # NEW
  belongs_to :fighter1, class_name: 'Fighter'
  belongs_to :fighter2, class_name: 'Fighter'
  belongs_to :winner, class_name: 'Fighter', optional: true

  belongs_to :fighter1_main, class_name: 'Weapon', optional: true
  belongs_to :fighter1_offhand, class_name: 'Weapon', optional: true
  belongs_to :fighter2_main, class_name: 'Weapon', optional: true
  belongs_to :fighter2_offhand, class_name: 'Weapon', optional: true

  has_many :penalties, dependent: :destroy

  validates :status, presence: true

  DEBUFFS = {
    'None' => 0,
    'Nerf Gun' => 0,
    'The Pig' => 5,
    'Swap Hands' => 4,
    'Hands Tied' => 4,
    'The Balloon' => 4,
    'Reverse Grip' => 4,
    'Hopping with feet together' => 3,
    '15 push-ups' => 3,
    'Anime Rules' => 3,
    'Kneeling' => 3,
    'Eyepatch' => 2,
    'Nose-peg' => 2,
    'Wrist Weights (450g)' => 1,
    'Wrist Weights (900g)' => 2,
    'Wrist Weights (1.35g)' => 3,
    'Wrist Weights (1.8kg)' => 4
  }

  MAX_POINTS = 12
  MAX_DURATION = 180 # 3 minutes in seconds
  WEAPON_BUDGET = 7

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

  # Calculate bonus points for a fighter
  def calculate_bonus_points(fighter_number)
    if fighter_number == 1
      weapon_cost = (fighter1_main&.cost || 0) + (fighter1_offhand&.cost || 0)
      unspent_points = WEAPON_BUDGET - weapon_cost
      debuff_bonus = DEBUFFS[fighter1_debuff] || 0
      unspent_points + debuff_bonus
    else
      weapon_cost = (fighter2_main&.cost || 0) + (fighter2_offhand&.cost || 0)
      unspent_points = WEAPON_BUDGET - weapon_cost
      debuff_bonus = DEBUFFS[fighter2_debuff] || 0
      unspent_points + debuff_bonus
    end
  end

  # Calculate starting points based on bonus point difference
  def calculate_starting_points
    fighter1_bonus = calculate_bonus_points(1)
    fighter2_bonus = calculate_bonus_points(2)

    difference = fighter1_bonus - fighter2_bonus

    if difference > 0
      self.fighter1_starting_points = difference
      self.fighter2_starting_points = 0
    elsif difference < 0
      self.fighter1_starting_points = 0
      self.fighter2_starting_points = difference.abs
    else
      self.fighter1_starting_points = 0
      self.fighter2_starting_points = 0
    end

    save
  end

  def fighter1_penalties
    penalties.where(fighter_id: fighter1_id).recent
  end

  def fighter2_penalties
    penalties.where(fighter_id: fighter2_id).recent
  end

  after_update :update_bracket_completion, if: :saved_change_to_status?

  private

  def update_bracket_completion
    if bracket.present? && status == 'completed' && winner_id.present?
      bracket.complete_bracket(winner_id)
    end
  end
end
