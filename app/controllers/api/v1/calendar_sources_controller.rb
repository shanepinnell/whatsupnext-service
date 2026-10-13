class Api::V1::CalendarSourcesController < Api::V1::BaseController
  before_action :authenticate_device, :block_unsupported_device

  def show
    calendar_source = @device.room.calendar_source
    return render json: { error: "no_calendar_source" }, status: :not_found unless calendar_source

    render json: { provider: calendar_source.provider, credential_digest: calendar_source.credential_digest, config: calendar_source.config }
  end
end
