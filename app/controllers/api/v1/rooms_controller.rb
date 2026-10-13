class Api::V1::RoomsController < Api::V1::BaseController
  before_action :authenticate_device

  def show
    @device.touch(:last_seen_at)
    return render json: { error: "unsupported_device" }, status: :forbidden if @device.support_stage == :unsupported && !@device.support_risk_accepted?

    room = @device.room
    render json: { room: { name: room.name, timezone: room.floor.building.site.timezone } }
  end
end
