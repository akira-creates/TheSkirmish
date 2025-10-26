class Bracket < ApplicationRecord
  belongs_to :fighter1, class_name: 'Fighter', optional: true
  belongs_to :fighter2, class_name: 'Fighter', optional: true
  belongs_to :winner, class_name: 'Fighter', optional: true

  validates :round, presence: true
  validates :position, presence: true
  validates :bracket_type, presence: true

  BRACKET_TYPES = [ 'winners', 'losers', 'finals' ]

  scope :winners_bracket, -> { where(bracket_type: 'winners') }
  scope :losers_bracket, -> { where(bracket_type: 'losers') }
  scope :finals, -> { where(bracket_type: 'finals') }

  def complete_bracket(winner_id)
    loser_id = fighter1_id == winner_id ? fighter2_id : fighter1_id
    update(winner_id: winner_id, loser_id: loser_id, completed: true)
    advance_winner
    advance_loser if bracket_type == 'winners'
  end

  def display_name
    if bracket_type == 'finals'
      "Grand Finals"
    else
      "#{bracket_type.capitalize} R#{round}-#{position}"
    end
  end

  private

  def advance_winner
    if bracket_type == 'winners'
      next_round = round + 1
      next_position = (position / 2.0).ceil

      next_bracket = Bracket.find_or_create_by(
        round: next_round, 
        position: next_position,
        bracket_type: 'winners'
      )

      if position.odd?
        next_bracket.update(fighter1_id: winner_id)
      else
        next_bracket.update(fighter2_id: winner_id)
      end
    elsif bracket_type == 'losers'
      # Advance to next losers round or finals
      # Implementation depends on bracket structure
    end
  end

  def advance_loser
    # Send loser to losers bracket
    # This needs custom logic based on round structure
  end
end
