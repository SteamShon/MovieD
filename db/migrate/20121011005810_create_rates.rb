class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.integer :user_id
      t.integer :tag_id
      t.integer :movie_id
      t.integer :rate

      t.timestamps
    end
    add_index :rates, [:user_id, :tag_id]
  end
end
