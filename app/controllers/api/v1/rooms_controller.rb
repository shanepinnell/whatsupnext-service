class Api::V1::RoomsController < Api::V1::BaseController
  before_action :authenticate_device

  def show
    @device.touch(:last_seen_at)
    return render json: { error: "unsupported_device" }, status: :forbidden if @device.support_stage == :unsupported && !@device.support_risk_accepted?

    room = @device.room
    calendar_source = room.calendar_source
    render json: { room: {
      name: room.name,
      timezone: room.floor.building.site.timezone,
      background_image_url: (rails_blob_url(room.background_image) if room.background_image.attached?),
      calendar_source: (calendar_source && { provider: calendar_source.provider, credential_digest: calendar_source.credential_digest })
    } }
  end
end
