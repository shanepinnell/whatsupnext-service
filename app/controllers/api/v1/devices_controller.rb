class Api::V1::DevicesController < Api::V1::BaseController
  before_action :authenticate_device

  def update
    if @device.update(device_info_params)
      head :no_content
    else
      render json: { error: "invalid_device_info" }, status: :unprocessable_content
    end
  end
end
