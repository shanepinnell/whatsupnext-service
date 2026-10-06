class Api::V1::Devices::InfosController < Api::V1::BaseController
  before_action :authenticate_device

  def create
    if @device.update(device_info_params)
      head :no_content
    else
      render json: { error: "invalid_device_info" }, status: :unprocessable_content
    end
  end
end
