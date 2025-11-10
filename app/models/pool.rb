class Pool < ApplicationRecord
  has_many :pool_fighters, dependent: :destroy
  has_many :fighters, through: :pool_fighters
  has_many :matches, dependent: :destroy

  validates :name, presence: true

  before_create :set_defaults

  def generate_matches
    fighter_list = fighters.to_a
    scheduled_matches = round_robin_schedule(fighter_list)

    scheduled_matches.each do |f1, f2|
      matches.create!(
        fighter1: f1,
        fighter2: f2,
        status: 'pending',
        fighter1_points: 0,
        fighter2_points: 0
      )
    end
  end

  def complete_pool
    update(completed: true, status: 'completed')
    calculate_standings
  end

  def all_matches_completed?
    matches.where(status: 'pending').empty?
  end

  private

  # Round-robin scheduling using the circle method
  # Ensures no fighter has more than 2 consecutive matches
  def round_robin_schedule(fighter_list)
    fighters = fighter_list.dup
    scheduled_matches = []

    # Handle odd number of fighters by adding a bye
    has_bye = fighters.size.odd?
    fighters << nil if has_bye

    n = fighters.size
    rounds = n - 1
    matches_per_round = n / 2

    # Use circle method: fix first fighter, rotate others
    rounds.times do |round|
      matches_per_round.times do |match|
        home = (round - match) % (n - 1)
        away = (n - 1 - match + round) % (n - 1)

        # Adjust indices for fixed first fighter
        home = n - 1 if match == 0

        fighter1 = fighters[home]
        fighter2 = fighters[away]

        # Skip bye rounds
        next if fighter1.nil? || fighter2.nil?

        scheduled_matches << [fighter1, fighter2]
      end
    end

    scheduled_matches
  end

  def set_defaults
    self.status ||= 'active'
    self.completed ||= false
    self.pool_size ||= 5
  end

  def calculate_standings
    fighters.each do |fighter|
      pool_matches = matches.where('fighter1_id = ? OR fighter2_id = ?', fighter.id, fighter.id)
                           .where(status: 'completed')

      wins = pool_matches.where(winner_id: fighter.id).count
      losses = pool_matches.count - wins
      total_points = pool_matches.sum do |match|
        if match.fighter1_id == fighter.id
          match.fighter1_points || 0
        else
          match.fighter2_points || 0
        end
      end
      total_points_against = pool_matches.sum do |match|
        if match.fighter1_id == fighter.id
          match.fighter2_points || 0
        else
          match.fighter1_points || 0
        end
      end

      fighter.update(wins: wins, losses: losses, points: total_points, points_against: total_points_against)
    end
  end
end
