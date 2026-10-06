class SupportRiskAcceptancesController < ApplicationController
  # POST /devices/1/support_risk_acceptance
  def create
    device = Device.find(params.expect(:device_id))
    device.accept_support_risk!(by: Current.user)
    redirect_to device, notice: "Risk accepted."
  rescue ActiveRecord::RecordInvalid
    redirect_to device, alert: "This Apple TV is supported, so there's no risk to accept."
  end
end
