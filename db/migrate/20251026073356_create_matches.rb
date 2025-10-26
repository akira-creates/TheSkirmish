class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.references :pool, null: false, foreign_key: true
      t.references :fighter1, null: false, foreign_key: true
      t.references :fighter2, null: false, foreign_key: true
      t.references :winner, null: false, foreign_key: true
      t.string :status
      t.string :fighter1_main
      t.string :fighter1_offhand
      t.string :fighter1_debuff
      t.string :fighter2_main
      t.string :fighter2_offhand
      t.string :fighter2_debuff
      t.integer :fighter1_points
      t.integer :fighter2_points

      t.timestamps
    end
    # Add these after the table creation
    add_foreign_key :matches, :weapons, column: :fighter1_main_id
    add_foreign_key :matches, :weapons, column: :fighter1_offhand_id
    add_foreign_key :matches, :weapons, column: :fighter2_main_id
    add_foreign_key :matches, :weapons, column: :fighter2_offhand_id
  end
end
