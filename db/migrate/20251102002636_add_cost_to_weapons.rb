class AddCostToWeapons < ActiveRecord::Migration[8.0]
  def change
    add_column :weapons, :cost, :integer, default: 0
  end
end
