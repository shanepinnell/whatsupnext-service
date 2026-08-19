class CreateFloors < ActiveRecord::Migration[8.1]
  def change
    create_table :floors do |t|
      t.string :name
      t.integer :position, null: false
      t.references :building, null: false, foreign_key: true

      t.timestamps
    end

    add_index :floors, [ :building_id, :name ], unique: true
    add_index :floors, [ :building_id, :position ], unique: true
  end
end
