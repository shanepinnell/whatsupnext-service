require "test_helper"

class Api::V1::Devices::InfosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), api_key: "device-key")
  end

  test "records the reported name and model" do
    post api_v1_devices_info_url, params: { name: "Lobby TV", model_identifier: "AppleTV14,1" }, headers: auth_headers, as: :json

    assert_response :no_content
    @device.reload
    assert_equal "Lobby TV", @device.name
    assert_equal "AppleTV14,1", @device.model_identifier
  end

  test "leaves values the report omits unchanged" do
    @device.update!(name: "Lobby TV", model_identifier: "AppleTV14,1")

    post api_v1_devices_info_url, params: { name: "Boardroom TV" }, headers: auth_headers, as: :json

    assert_response :no_content
    assert_equal "AppleTV14,1", @device.reload.model_identifier
  end

  test "defaults a blank name to Apple TV" do
    @device.update!(name: "Lobby TV")

    post api_v1_devices_info_url, params: { name: "" }, headers: auth_headers, as: :json

    assert_equal "Apple TV", @device.reload.name
  end

  test "rejects a request without an api key" do
    post api_v1_devices_info_url, params: { name: "Lobby TV" }, as: :json

    assert_response :unauthorized
    assert_equal "invalid_api_key", response.parsed_body["error"]
  end

  test "rejects an unknown api key" do
    post api_v1_devices_info_url, params: { name: "Lobby TV" }, headers: { "Authorization" => "Bearer wrong-key" }, as: :json

    assert_response :unauthorized
    assert_equal "invalid_api_key", response.parsed_body["error"]
  end

  test "rejects the api key of a deleted device" do
    @device.destroy!

    post api_v1_devices_info_url, params: { name: "Lobby TV" }, headers: auth_headers, as: :json

    assert_response :unauthorized
    assert_equal "invalid_api_key", response.parsed_body["error"]
  end

  private
    def auth_headers
      { "Authorization" => "Bearer device-key" }
    end
end
