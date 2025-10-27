class Fighter < ApplicationRecord
  has_many :pool_fighters, dependent: :destroy
  has_many :pools, through: :pool_fighters

  has_many :matches_as_fighter1, class_name: 'Match', foreign_key: 'fighter1_id'
  has_many :matches_as_fighter2, class_name: 'Match', foreign_key: 'fighter2_id'
  has_many :matches_won, class_name: 'Match', foreign_key: 'winner_id'

  has_many :brackets_as_fighter1, class_name: 'Bracket', foreign_key: 'fighter1_id'
  has_many :brackets_as_fighter2, class_name: 'Bracket', foreign_key: 'fighter2_id'

  validates :name, presence: true
  validates :club, presence: true

  before_create :initialize_stats

  def all_matches
    Match.where('fighter1_id = ? OR fighter2_id = ?', id, id)
  end

  def pool_record
    pool_matches = all_matches.where.not(pool_id: nil).where(status: 'completed')
    wins = pool_matches.where(winner_id: id).count
    losses = pool_matches.count - wins
    "#{wins}-#{losses}"
  end

  private

  def initialize_stats
    self.wins ||= 0
    self.losses ||= 0
    self.points ||= 0
    self.eliminated ||= false
  end
end
