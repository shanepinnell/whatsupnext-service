class Api::V1::Devices::InfosController < Api::V1::BaseController
  before_action :authenticate_device

  def create
    @device.update!(info_params)
    head :no_content
  end

  private
    def info_params
      params.permit(:name, :model_identifier).tap do |info|
        info[:name] = info[:name].presence || Device::DEFAULT_NAME if info.key?(:name)
      end
    end
end
