class Api::V1::DevicesController < Api::V1::BaseController
  POLL_INTERVAL_SECONDS = 5

  before_action :authenticate_device, only: :update

  def create
    identifier = request.headers["X-Device-Identifier"]
    return render json: { error: "missing_device_identifier" }, status: :bad_request if identifier.blank?

    device = Device.find_or_initialize_by(device_identifier: identifier)
    return render json: { error: "device_paired" }, status: :conflict if device.paired?

    device.assign_attributes(device_info_params)
    device.issue_pairing_code
    return render json: { error: "invalid_device_info" }, status: :unprocessable_content unless device.save

    render json: { code: device.pairing_code, expires_at: device.pairing_code_expires_at, poll_interval_seconds: POLL_INTERVAL_SECONDS }, status: :created
  end

  def pairing_status
    identifier = request.headers["X-Device-Identifier"]
    return render json: { error: "missing_device_identifier" }, status: :bad_request if identifier.blank?

    device = Device.find_by(device_identifier: identifier)
    return render json: { error: "unknown_device" }, status: :not_found unless device
    return render json: { status: "pending" } if device.pending?

    render json: { status: "paired", api_key: device.deliver_api_key!, room: { name: device.room.name } }.compact
  end

  def update
    if @device.update(device_info_params)
      head :no_content
    else
      render json: { error: "invalid_device_info" }, status: :unprocessable_content
    end
  end
end
