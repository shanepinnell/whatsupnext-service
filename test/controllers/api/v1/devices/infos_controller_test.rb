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

  test "records the reported tvOS and App versions" do
    post api_v1_devices_info_url, params: { os_version: "27.0", app_version: "1.0 (42)" }, headers: auth_headers, as: :json

    assert_response :no_content
    @device.reload
    assert_equal "27.0", @device.os_version
    assert_equal "1.0 (42)", @device.app_version
  end

  test "records the reported display" do
    post api_v1_devices_info_url, params: { display: { width: 3840, height: 2160, hdr: true } }, headers: auth_headers, as: :json

    assert_response :no_content
    @device.reload
    assert_equal 3840, @device.display_width
    assert_equal 2160, @device.display_height
    assert @device.display_hdr
  end

  test "records the reported network" do
    post api_v1_devices_info_url, params: { network: "ethernet" }, headers: auth_headers, as: :json

    assert_response :no_content
    assert_equal "ethernet", @device.reload.network
  end

  test "records when the device last reported its info" do
    freeze_time do
      post api_v1_devices_info_url, params: { os_version: "27.0" }, headers: auth_headers, as: :json

      assert_equal Time.current, @device.reload.info_reported_at
    end
  end

  test "rejects an unknown network and records nothing" do
    post api_v1_devices_info_url, params: { os_version: "27.0", network: "carrier_pigeon" }, headers: auth_headers, as: :json

    assert_response :unprocessable_content
    assert_equal "invalid_device_info", response.parsed_body["error"]
    @device.reload
    assert_nil @device.os_version
    assert_nil @device.network
  end

  test "an empty report records nothing" do
    post api_v1_devices_info_url, headers: auth_headers, as: :json

    assert_response :no_content
    assert_nil @device.reload.info_reported_at
  end

  private
    def auth_headers
      { "Authorization" => "Bearer device-key" }
    end
end
