class CreateBrackets < ActiveRecord::Migration[8.0]
  def change
    create_table :brackets do |t|
      t.integer :round
      t.integer :position
      t.bigint :fighter1_id
      t.bigint :fighter2_id
      t.bigint :winner_id
      t.boolean :completed

      t.timestamps
    end

    add_foreign_key :brackets, :fighters, column: :fighter1_id
    add_foreign_key :brackets, :fighters, column: :fighter2_id
    add_foreign_key :brackets, :fighters, column: :winner_id
  end
end
