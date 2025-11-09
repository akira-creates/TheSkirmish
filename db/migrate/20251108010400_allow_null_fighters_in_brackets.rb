class AllowNullFightersInBrackets < ActiveRecord::Migration[8.0]
  def change
    change_column_null :brackets, :fighter1_id, true
    change_column_null :brackets, :fighter2_id, true
    change_column_null :brackets, :winner_id, true
  end
end
