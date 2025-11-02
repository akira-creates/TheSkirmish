class CreatePenalties < ActiveRecord::Migration[8.0]
  def change
    create_table :penalties do |t|
      t.references :fighter, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true
      t.string :card_type, null: false
      t.text :reason
      t.datetime :issued_at, null: false

      t.timestamps
    end

    add_index :penalties, [ :fighter_id, :issued_at ]
    add_index :penalties, :card_type
  end
end
