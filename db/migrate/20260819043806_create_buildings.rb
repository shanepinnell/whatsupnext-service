class CreateBuildings < ActiveRecord::Migration[8.1]
  def change
    create_table :buildings do |t|
      t.string :name
      t.string :timezone
      t.references :site, null: false, foreign_key: true

      t.timestamps
    end

    add_index :buildings, [ :site_id, :name ], unique: true
  end
end
