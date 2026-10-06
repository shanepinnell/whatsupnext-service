class Api::V1::Devices::InfosController < Api::V1::BaseController
  before_action :authenticate_device

  def create
    if @device.update(info_params)
      head :no_content
    else
      render json: { error: "invalid_device_info" }, status: :unprocessable_content
    end
  end

  private
    def info_params
      info = params.permit(:name, :model_identifier, :os_version, :app_version, :network, display: %i[ width height hdr ])
      info[:name] = info[:name].presence || Device::DEFAULT_NAME if info.key?(:name)
      display = info.delete(:display)
      info.merge!(display.transform_keys { |key| "display_#{key}" }) if display
      info.merge(info_reported_at: Time.current)
    end
end
