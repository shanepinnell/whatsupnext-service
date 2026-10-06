class AddDeviceInfoToDevices < ActiveRecord::Migration[8.1]
  def change
    add_column :devices, :os_version, :string
    add_column :devices, :app_version, :string
    add_column :devices, :display_width, :integer
    add_column :devices, :display_height, :integer
    add_column :devices, :display_hdr, :boolean
    add_column :devices, :network, :integer
    add_column :devices, :info_reported_at, :datetime
  end
end
