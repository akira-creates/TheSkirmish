class Pool < ApplicationRecord
  has_many :pool_fighters, dependent: :destroy
  has_many :fighters, through: :pool_fighters
  has_many :matches, dependent: :destroy

  validates :name, presence: true

  before_create :set_defaults

  def generate_matches
    fighter_list = fighters.to_a

    fighter_list.combination(2).each do |f1, f2|
      matches.create!(
        fighter1: f1,
        fighter2: f2,
        status: 'pending',
        fightrt1_points: 0,
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
