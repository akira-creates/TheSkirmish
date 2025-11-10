class UpdateBracketTypes < ActiveRecord::Migration[8.0]
  def up
    # Update existing bracket types from old names to new names
    execute "UPDATE brackets SET bracket_type = 'upper' WHERE bracket_type = 'winners'"
    execute "UPDATE brackets SET bracket_type = 'lower' WHERE bracket_type = 'losers'"
  end

  def down
    # Revert back to old names if needed
    execute "UPDATE brackets SET bracket_type = 'winners' WHERE bracket_type = 'upper'"
    execute "UPDATE brackets SET bracket_type = 'losers' WHERE bracket_type = 'lower'"
  end
end
