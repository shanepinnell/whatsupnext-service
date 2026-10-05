class Api::V1::Devices::PairingCodesController < Api::V1::BaseController
  POLL_INTERVAL_SECONDS = 5

  def create
    identifier = request.headers["X-Device-Identifier"]
    return render json: { error: "missing_device_identifier" }, status: :bad_request if identifier.blank?

    device = Device.find_or_initialize_by(device_identifier: identifier)
    if device.paired?
      return render json: { error: "device_paired" }, status: :conflict
    elsif device.revoked?
      return render json: { error: "device_revoked" }, status: :conflict
    end

    device.name = params[:name] if params.key?(:name)
    device.issue_pairing_code
    device.save!
    render json: { code: device.pairing_code, expires_at: device.pairing_code_expires_at, poll_interval_seconds: POLL_INTERVAL_SECONDS }, status: :created
  end
end
