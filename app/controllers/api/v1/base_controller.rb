class Api::V1::BaseController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  private
    def authenticate_device
      @device = authenticate_with_http_token { |api_key| Device.authenticated_by(api_key) }
      render json: { error: "invalid_api_key" }, status: :unauthorized unless @device
    end
end
