class MoveTimezoneFromBuildingsToSites < ActiveRecord::Migration[8.1]
  def up
    add_column :sites, :timezone, :string
    execute <<~SQL
      UPDATE sites SET timezone = (
        SELECT timezone FROM buildings WHERE buildings.site_id = sites.id ORDER BY buildings.id LIMIT 1
      )
    SQL
    remove_column :buildings, :timezone
  end

  def down
    add_column :buildings, :timezone, :string
    execute <<~SQL
      UPDATE buildings SET timezone = (SELECT timezone FROM sites WHERE sites.id = buildings.site_id)
    SQL
    remove_column :sites, :timezone
  end
end
