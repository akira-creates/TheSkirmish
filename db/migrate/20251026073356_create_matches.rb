class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.references :pool, null: false, foreign_key: true
      t.bigint :fighter1_id
      t.bigint :fighter2_id
      t.bigint :winner_id
      t.string :status
      t.bigint :fighter1_main_id
      t.bigint :fighter1_offhand_id
      t.string :fighter1_debuff
      t.bigint :fighter2_main_id
      t.bigint :fighter2_offhand_id
      t.string :fighter2_debuff
      t.integer :fighter1_points
      t.integer :fighter2_points
      t.integer :fighter1_starting_points, default: 0
      t.integer :fighter2_starting_points, default: 0
      t.integer :duration

      t.timestamps
    end

    # Add foreign keys to fighters table
    add_foreign_key :matches, :fighters, column: :fighter1_id
    add_foreign_key :matches, :fighters, column: :fighter2_id
    add_foreign_key :matches, :fighters, column: :winner_id

    # Add foreign keys to weapons table
    add_foreign_key :matches, :weapons, column: :fighter1_main_id
    add_foreign_key :matches, :weapons, column: :fighter1_offhand_id
    add_foreign_key :matches, :weapons, column: :fighter2_main_id
    add_foreign_key :matches, :weapons, column: :fighter2_offhand_id
  end
end
