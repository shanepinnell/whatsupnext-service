class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  private
    def authenticate_device
      @device = authenticate_with_http_token { |api_key| Device.authenticated_by(api_key) }
      render json: { error: "invalid_api_key" }, status: :unauthorized unless @device
    end

    def device_info_params
      info = params.permit(:name, :model_identifier, :os_version, :app_version, :network, display: %i[ width height hdr ])
      return info if info.empty?

      info[:name] = info[:name].presence || Device::DEFAULT_NAME if info.key?(:name)
      display = info.delete(:display)
      info.merge!(display.transform_keys { |key| "display_#{key}" }) if display
      info.merge(info_reported_at: Time.current)
    end
end
