class CreateSites < ActiveRecord::Migration[8.1]
  def change
    create_table :sites do |t|
      t.string :name
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :sites, [ :organization_id, :name ], unique: true
  end
end
