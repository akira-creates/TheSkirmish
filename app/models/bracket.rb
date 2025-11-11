class Bracket < ApplicationRecord
  belongs_to :fighter1, class_name: 'Fighter', optional: true
  belongs_to :fighter2, class_name: 'Fighter', optional: true
  belongs_to :winner, class_name: 'Fighter', optional: true
  belongs_to :loser, class_name: 'Fighter', optional: true
  belongs_to :match, optional: true

  validates :round, presence: true
  validates :position, presence: true
  validates :bracket_type, presence: true

  BRACKET_TYPES = ['upper', 'lower', 'finals'].freeze

  scope :upper_bracket, -> { where(bracket_type: 'upper') }
  scope :lower_bracket, -> { where(bracket_type: 'lower') }
  scope :finals, -> { where(bracket_type: 'finals') }
  scope :completed, -> { where(completed: true) }

  def ready_to_fight?
    fighter1.present? && fighter2.present? && !completed
  end

  def create_match
    return unless ready_to_fight?
    return if match.present?

    new_match = Match.create!(
      bracket: self,
      fighter1: fighter1,
      fighter2: fighter2,
      status: 'pending',
      fighter1_points: 0,
      fighter2_points: 0
    )

    update(match: new_match)
  end

  def complete_bracket(winner_id)
    return unless match&.status == 'completed'

    loser_id = fighter1_id == winner_id ? fighter2_id : fighter1_id

    update(winner_id: winner_id, loser_id: loser_id, completed: true)

    advance_winner(winner_id)
    advance_loser(loser_id) if bracket_type == 'upper'

    if bracket_type == 'finals'
      Fighter.find_by(id: winner_id)&.update(eliminated: false)
      Fighter.find_by(id: loser_id)&.update(eliminated: true)
    elsif bracket_type == 'lower'
      Fighter.find_by(id: loser_id)&.update(eliminated: true)
    end
  end

  def display_name
    case bracket_type
    when 'finals'
      'Grand Finals'
    when 'upper'
      "Upper R#{round}-#{position}"
    when 'lower'
      "Lower R#{round}-#{position}"
    end
  end

  private

  def advance_winner(winner_id)
    case bracket_type
    when 'upper'
      advance_in_upper_bracket(winner_id)
    when 'lower'
      advance_in_lower_bracket(winner_id)
    when 'finals'
      # No advancement after finals
    end
  end

  def advance_in_upper_bracket(winner_id)
    total_upper_rounds = Bracket.upper_bracket.maximum(:round)

    if round == total_upper_rounds
      # Winner of final upper bracket round goes to finals
      finals_bracket = Bracket.find_by(bracket_type: 'finals')
      assign_fighter_to_slot(finals_bracket, winner_id) if finals_bracket
    else
      # Advance to next round in upper bracket
      next_round = round + 1
      next_position = ((position + 1) / 2.0).ceil

      next_bracket = Bracket.find_by(
        bracket_type: 'upper',
        round: next_round,
        position: next_position
      )

      assign_fighter_to_slot(next_bracket, winner_id) if next_bracket
    end
  end

  def advance_in_lower_bracket(winner_id)
    total_lower_rounds = Bracket.lower_bracket.maximum(:round)

    if round == total_lower_rounds
      # Winner of final lower bracket round goes to finals
      finals_bracket = Bracket.find_by(bracket_type: 'finals')
      assign_fighter_to_slot(finals_bracket, winner_id) if finals_bracket
    else
      # Advance to next round in lower bracket
      next_round = round + 1
      next_position = ((position + 1) / 2.0).ceil

      next_bracket = Bracket.find_by(
        bracket_type: 'lower',
        round: next_round,
        position: next_position
      )

      assign_fighter_to_slot(next_bracket, winner_id) if next_bracket
    end
  end

  def advance_loser(loser_id)
    return unless loser_id

    # In double elimination, losers from upper bracket drop to lower bracket
    # Losers are paired up: two adjacent upper bracket positions feed into one lower bracket position
    # UB R1 losers → LB R1
    # UB R2 losers → LB R2 (feed into winners from LB R1)
    # UB R3 losers → LB R4 (feed into winners from LB R3)
    # Formula: UB RN losers → LB R(2N-2) for N > 1

    target_round = if round == 1
      1
    else
      (round * 2) - 2
    end

    # Two upper bracket matches feed into one lower bracket match
    # Positions 1 & 2 → LB position 1, positions 3 & 4 → LB position 2, etc.
    target_position = ((position + 1) / 2.0).ceil

    next_bracket = Bracket.find_by(
      bracket_type: 'lower',
      round: target_round,
      position: target_position
    )

    if next_bracket
      assign_fighter_to_slot(next_bracket, loser_id)
    else
      Fighter.find_by(id: loser_id)&.update(eliminated: true)
    end
  end

  def assign_fighter_to_slot(bracket, fighter_id)
    return unless bracket

    if bracket.fighter1_id.nil?
      bracket.update(fighter1_id: fighter_id)
    elsif bracket.fighter2_id.nil?
      bracket.update(fighter2_id: fighter_id)
      # Automatically create match when both fighters are assigned
      bracket.create_match if bracket.ready_to_fight?
    else
      Rails.logger.warn "Bracket #{bracket.id} already full"
    end
  end
end