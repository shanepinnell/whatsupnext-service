class AddModelIdentifierToDevices < ActiveRecord::Migration[8.1]
  def change
    add_column :devices, :model_identifier, :string
  end
end
