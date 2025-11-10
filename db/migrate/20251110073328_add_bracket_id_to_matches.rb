class AddBracketIdToMatches < ActiveRecord::Migration[8.0]
  def change
    add_reference :matches, :bracket, null: true, foreign_key: true
  end
end
