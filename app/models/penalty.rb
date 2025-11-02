class Penalty < ApplicationRecord
  belongs_to :fighter
  belongs_to :match

  validates :card_type, presence: true, inclusion: { in: %w[yellow red black] }
  validates :issued_at, presence: true

  CARD_TYPES = {
    'yellow' => {
      name: 'Yellow Card',
      description: 'Warning for minor offences',
      point_deduction: 0,
      color: 'yellow'
    },
    'red' => {
      name: 'Red Card',
      description: 'Major offence or repeated minor offences',
      point_deduction: 3,
      color: 'red'
    },
    'black' => {
      name: 'Black Card',
      description: 'Expulsion from tournament',
      point_deduction: 0,
      color: 'black'
    }
  }

  scope :yellow_cards, -> { where(card_type: 'yellow') }
  scope :red_cards, -> { where(card_type: 'red') }
  scope :black_cards, -> { where(card_type: 'black') }
  scope :recent, -> { order(issued_at: :desc) }

  def self.for_current_match(fighter_id, match_id)
    where(fighter_id: fighter_id, match_id: match_id).recent
  end

  def card_info
    CARD_TYPES[card_type]
  end

  def display_name
    card_info[:name]
  end

  def point_deduction
    card_info[:point_deduction]
  end
end
