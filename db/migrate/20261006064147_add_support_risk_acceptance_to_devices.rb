class AddSupportRiskAcceptanceToDevices < ActiveRecord::Migration[8.1]
  def change
    add_column :devices, :support_risk_accepted_stage, :string
    add_column :devices, :support_risk_accepted_at, :datetime
    add_reference :devices, :support_risk_accepted_by, foreign_key: { to_table: :users, on_delete: :nullify }
  end
end
