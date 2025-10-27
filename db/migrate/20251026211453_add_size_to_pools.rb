class AddSizeToPools < ActiveRecord::Migration[8.0]
  def change
    add_column :pools, :pool_size, :integer
  end
end
