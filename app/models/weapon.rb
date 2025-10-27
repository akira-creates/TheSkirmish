class Weapon < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :weapon_type, presence: true

  WEAPON_TYPES = [ 'Main Hand', 'Off Hand' ]

  scope :main_hand, -> { where(weapon_type: [ 'Main Hand', 'Off Hand' ]) }
  scope :off_hand, -> { where(weapon_type: [ 'Off Hand', 'Main Hand' ]) }
end
