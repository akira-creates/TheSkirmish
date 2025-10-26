class CreateBrackets < ActiveRecord::Migration[8.0]
  def change
    create_table :brackets do |t|
      t.integer :round
      t.integer :position
      t.references :fighter1, null: false, foreign_key: true
      t.references :fighter2, null: false, foreign_key: true
      t.references :winner, null: false, foreign_key: true
      t.boolean :completed

      t.timestamps
    end
  end
end
