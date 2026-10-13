require "test_helper"

class Api::V1::DevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), api_key: "device-key")
  end

  test "creates a pending device with a fresh code for a new device_identifier" do
    identifier = SecureRandom.uuid

    assert_difference "Device.count", 1 do
      post api_v1_devices_url, headers: { "X-Device-Identifier" => identifier }, as: :json
    end

    assert_response :created
    device = Device.find_by!(device_identifier: identifier)
    assert device.pending?
    body = response.parsed_body
    assert_equal device.pairing_code, body["code"]
    assert_equal device.pairing_code_expires_at.iso8601(3), body["expires_at"]
    assert_equal 5, body["poll_interval_seconds"]
  end

  test "reissues a code on the existing pending device for a known device_identifier" do
    device = Device.create!(device_identifier: SecureRandom.uuid, pairing_code: "123456", pairing_code_expires_at: 1.minute.from_now)

    assert_no_difference "Device.count" do
      post api_v1_devices_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json
    end

    assert_response :created
    assert_equal device.reload.pairing_code, response.parsed_body["code"]
    assert_operator device.pairing_code_expires_at, :>, 14.minutes.from_now
  end

  test "refuses a code for a paired device_identifier" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), api_key: "existing-key")

    post api_v1_devices_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :conflict
    assert_equal "device_paired", response.parsed_body["error"]
    assert_nil device.reload.pairing_code
  end

  test "rejects a request with no X-Device-Identifier header" do
    assert_no_difference "Device.count" do
      post api_v1_devices_url, as: :json
    end

    assert_response :bad_request
    assert_equal "missing_device_identifier", response.parsed_body["error"]
  end

  test "rejects a request with a blank X-Device-Identifier header" do
    assert_no_difference "Device.count" do
      post api_v1_devices_url, headers: { "X-Device-Identifier" => " " }, as: :json
    end

    assert_response :bad_request
    assert_equal "missing_device_identifier", response.parsed_body["error"]
  end

  test "sets the device name from the request body" do
    identifier = SecureRandom.uuid

    post api_v1_devices_url, params: { name: "Shane’s Apple TV" }, headers: { "X-Device-Identifier" => identifier }, as: :json

    assert_response :created
    assert_equal "Shane’s Apple TV", Device.find_by!(device_identifier: identifier).name
  end

  test "updates the device name on reissue" do
    device = Device.create!(device_identifier: SecureRandom.uuid, name: "Apple TV")

    post api_v1_devices_url, params: { name: "Lobby" }, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :created
    assert_equal "Lobby", device.reload.name
  end

  test "keeps the existing name when a reissue omits it" do
    device = Device.create!(device_identifier: SecureRandom.uuid, name: "Lobby")

    post api_v1_devices_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_equal "Lobby", device.reload.name
  end

  test "uses the default name when the request sends a blank one" do
    identifier = SecureRandom.uuid

    post api_v1_devices_url, params: { name: "  " }, headers: { "X-Device-Identifier" => identifier }, as: :json

    assert_response :created
    assert_equal "Apple TV", Device.find_by!(device_identifier: identifier).name
  end

  test "records device info sent with the code request" do
    identifier = SecureRandom.uuid

    post api_v1_devices_url, params: { model_identifier: "AppleTV5,3", os_version: "26.6", app_version: "1.0 (1)", display: { width: 1920, height: 1080, hdr: false }, network: "wifi" }, headers: { "X-Device-Identifier" => identifier }, as: :json

    assert_response :created
    device = Device.find_by!(device_identifier: identifier)
    assert_equal "AppleTV5,3", device.model_identifier
    assert_equal "26.6", device.os_version
    assert_equal "1.0 (1)", device.app_version
    assert_equal 1920, device.display_width
    assert_equal "wifi", device.network
    assert_not_nil device.info_reported_at
  end

  test "rejects an unknown network without issuing a code" do
    assert_no_difference "Device.count" do
      post api_v1_devices_url, params: { network: "carrier_pigeon" }, headers: { "X-Device-Identifier" => SecureRandom.uuid }, as: :json
    end

    assert_response :unprocessable_content
    assert_equal "invalid_device_info", response.parsed_body["error"]
  end

  test "a code request without device info doesn't count as a report" do
    identifier = SecureRandom.uuid

    post api_v1_devices_url, headers: { "X-Device-Identifier" => identifier }, as: :json

    assert_nil Device.find_by!(device_identifier: identifier).info_reported_at
  end

  test "reports pending until the device is claimed" do
    device = Device.create!(device_identifier: SecureRandom.uuid)

    get pairing_status_api_v1_devices_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :success
    assert_equal({ "status" => "pending" }, response.parsed_body)
  end

  test "delivers the api key and room on the first poll after claiming" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit))

    get pairing_status_api_v1_devices_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal "paired", body["status"]
    assert_equal({ "name" => rooms(:summit).name }, body["room"])
    assert_equal device, Device.authenticated_by(body["api_key"])
  end

  test "never delivers the api key a second time" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit))
    get pairing_status_api_v1_devices_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    get pairing_status_api_v1_devices_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :success
    assert_equal({ "status" => "paired", "room" => { "name" => rooms(:summit).name } }, response.parsed_body)
  end

  test "rejects a request without a device identifier" do
    get pairing_status_api_v1_devices_url, as: :json

    assert_response :bad_request
    assert_equal "missing_device_identifier", response.parsed_body["error"]
  end

  test "reports an unknown device identifier" do
    get pairing_status_api_v1_devices_url, headers: { "X-Device-Identifier" => SecureRandom.uuid }, as: :json

    assert_response :not_found
    assert_equal "unknown_device", response.parsed_body["error"]
  end

  test "records the reported name and model" do
    patch api_v1_device_url, params: { name: "Lobby TV", model_identifier: "AppleTV14,1" }, headers: auth_headers, as: :json

    assert_response :no_content
    @device.reload
    assert_equal "Lobby TV", @device.name
    assert_equal "AppleTV14,1", @device.model_identifier
  end

  test "leaves values the report omits unchanged" do
    @device.update!(name: "Lobby TV", model_identifier: "AppleTV14,1")

    patch api_v1_device_url, params: { name: "Boardroom TV" }, headers: auth_headers, as: :json

    assert_response :no_content
    assert_equal "AppleTV14,1", @device.reload.model_identifier
  end

  test "defaults a blank name to Apple TV" do
    @device.update!(name: "Lobby TV")

    patch api_v1_device_url, params: { name: "" }, headers: auth_headers, as: :json

    assert_equal "Apple TV", @device.reload.name
  end

  test "rejects a request without an api key" do
    patch api_v1_device_url, params: { name: "Lobby TV" }, as: :json

    assert_response :unauthorized
    assert_equal "invalid_api_key", response.parsed_body["error"]
  end

  test "rejects an unknown api key" do
    patch api_v1_device_url, params: { name: "Lobby TV" }, headers: { "Authorization" => "Bearer wrong-key" }, as: :json

    assert_response :unauthorized
    assert_equal "invalid_api_key", response.parsed_body["error"]
  end

  test "rejects the api key of a deleted device" do
    @device.destroy!

    patch api_v1_device_url, params: { name: "Lobby TV" }, headers: auth_headers, as: :json

    assert_response :unauthorized
    assert_equal "invalid_api_key", response.parsed_body["error"]
  end

  test "records the reported tvOS and App versions" do
    patch api_v1_device_url, params: { os_version: "27.0", app_version: "1.0 (42)" }, headers: auth_headers, as: :json

    assert_response :no_content
    @device.reload
    assert_equal "27.0", @device.os_version
    assert_equal "1.0 (42)", @device.app_version
  end

  test "records the reported display" do
    patch api_v1_device_url, params: { display: { width: 3840, height: 2160, hdr: true } }, headers: auth_headers, as: :json

    assert_response :no_content
    @device.reload
    assert_equal 3840, @device.display_width
    assert_equal 2160, @device.display_height
    assert @device.display_hdr
  end

  test "records the reported network" do
    patch api_v1_device_url, params: { network: "ethernet" }, headers: auth_headers, as: :json

    assert_response :no_content
    assert_equal "ethernet", @device.reload.network
  end

  test "records when the device last reported its info" do
    freeze_time do
      patch api_v1_device_url, params: { os_version: "27.0" }, headers: auth_headers, as: :json

      assert_equal Time.current, @device.reload.info_reported_at
    end
  end

  test "rejects an unknown network and records nothing" do
    patch api_v1_device_url, params: { os_version: "27.0", network: "carrier_pigeon" }, headers: auth_headers, as: :json

    assert_response :unprocessable_content
    assert_equal "invalid_device_info", response.parsed_body["error"]
    @device.reload
    assert_nil @device.os_version
    assert_nil @device.network
  end

  test "an empty report records nothing" do
    patch api_v1_device_url, headers: auth_headers, as: :json

    assert_response :no_content
    assert_nil @device.reload.info_reported_at
  end

  private
    def auth_headers
      { "Authorization" => "Bearer device-key" }
    end
end
