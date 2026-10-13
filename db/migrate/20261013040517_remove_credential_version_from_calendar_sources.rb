class RemoveCredentialVersionFromCalendarSources < ActiveRecord::Migration[8.1]
  def change
    remove_column :calendar_sources, :credential_version, :integer, default: 0, null: false
  end
end
