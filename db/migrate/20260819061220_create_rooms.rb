class CreateRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms do |t|
      t.string :name
      t.references :floor, null: false, foreign_key: true

      t.timestamps
    end

    add_index :rooms, [ :floor_id, :name ], unique: true
  end
end
