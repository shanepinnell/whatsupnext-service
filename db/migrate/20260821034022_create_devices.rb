class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.string :device_identifier
      t.references :room, foreign_key: true
      t.integer :status, null: false, default: 0
      t.string :api_key_digest
      t.string :apns_token
      t.string :mdm_device_id
      t.string :pairing_code
      t.datetime :pairing_code_expires_at
      t.datetime :paired_at
      t.datetime :last_seen_at

      t.timestamps
    end
    add_index :devices, :device_identifier, unique: true
    add_index :devices, :mdm_device_id, unique: true
  end
end
