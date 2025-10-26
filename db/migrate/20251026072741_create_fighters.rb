class CreateFighters < ActiveRecord::Migration[8.0]
  def change
    create_table :fighters do |t|
      t.string :name
      t.string :club
      t.integer :wins
      t.integer :losses
      t.integer :points
      t.integer :points_against
      t.boolean :eliminated

      t.timestamps
    end
  end
end
