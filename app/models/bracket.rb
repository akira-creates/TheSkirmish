class Bracket < ApplicationRecord
  belongs_to :fighter1, class_name: 'Fighter', optional: true
  belongs_to :fighter2, class_name: 'Fighter', optional: true
  belongs_to :winner, class_name: 'Fighter', optional: true

  validates :round, presence: true
  validates :position, presence: true

  def complete_bracket(winner_id)
    update(winner_id: winner_id, completed: true)
    advance_winner
  end

  private

  def advance_winner
    next_round = round + 1
    next_position = (position / 2.0).ceil

    next_bracket = Bracket.find_or_create_by(round: next_round, position: next_position)

    if position.odd?
      next_bracket.update(fighter1_id: winner_id)
    else
      next_bracket.update(fighter2_id: winner_id)
    end
  end
end
