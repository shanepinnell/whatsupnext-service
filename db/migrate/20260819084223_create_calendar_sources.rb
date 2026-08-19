class CreateCalendarSources < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_sources do |t|
      t.integer :provider
      t.text :config
      t.integer :credential_version, null: false, default: 0
      t.string :webhook_subscription_id
      t.datetime :webhook_expires_at
      t.references :room, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
