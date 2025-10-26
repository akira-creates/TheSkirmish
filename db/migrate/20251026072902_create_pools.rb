class CreatePools < ActiveRecord::Migration[8.0]
  def change
    create_table :pools do |t|
      t.string :name
      t.string :status
      t.boolean :completed

      t.timestamps
    end
  end
end
