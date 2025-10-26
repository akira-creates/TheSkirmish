class CreatePoolFighters < ActiveRecord::Migration[8.0]
  def change
    create_table :pool_fighters do |t|
      t.references :pool, null: false, foreign_key: true
      t.references :fighter, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
