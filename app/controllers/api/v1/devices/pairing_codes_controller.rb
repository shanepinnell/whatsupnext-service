class Api::V1::Devices::PairingCodesController < Api::V1::BaseController
  POLL_INTERVAL_SECONDS = 5

  def create
    device = Device.new(device_identifier: request.headers["X-Device-Identifier"])
    device.issue_pairing_code
    device.save!
    render json: { code: device.pairing_code, expires_at: device.pairing_code_expires_at, poll_interval_seconds: POLL_INTERVAL_SECONDS }, status: :created
  end
end
