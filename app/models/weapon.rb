class Weapon < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :weapon_type, presence: true
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }

  WEAPON_TYPES = [ 'Main Hand', 'Off Hand' ]

  scope :main_hand, -> { where(weapon_type: [ 'Main Hand', 'Off Hand' ]) }
  scope :off_hand, -> { where(weapon_type: [ 'Off Hand', 'Main Hand' ]) }
  scope :affordable, ->(points) { where('cost <= ?', points) }
end
