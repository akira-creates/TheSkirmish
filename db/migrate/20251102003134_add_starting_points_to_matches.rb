class AddStartingPointsToMatches < ActiveRecord::Migration[8.0]
  def change
    add_column :matches, :fighter1_starting_points, :integer, default: 0
    add_column :matches, :fighter2_starting_points, :integer, default: 0
  end
end
