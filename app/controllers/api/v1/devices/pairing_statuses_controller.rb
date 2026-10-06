class Api::V1::Devices::PairingStatusesController < Api::V1::BaseController
  def show
    identifier = request.headers["X-Device-Identifier"]
    return render json: { error: "missing_device_identifier" }, status: :bad_request if identifier.blank?

    device = Device.find_by(device_identifier: identifier)
    return render json: { error: "unknown_device" }, status: :not_found unless device
    return render json: { status: "pending" } if device.pending?

    render json: { status: "paired", api_key: device.deliver_api_key!, room: { name: device.room.name } }.compact
  end
end
