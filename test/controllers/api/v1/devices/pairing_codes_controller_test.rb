require "test_helper"

class Api::V1::Devices::PairingCodesControllerTest < ActionDispatch::IntegrationTest
  test "creates a pending device with a fresh code for a new device_identifier" do
    identifier = SecureRandom.uuid

    assert_difference "Device.count", 1 do
      post api_v1_devices_pairing_codes_url, headers: { "X-Device-Identifier" => identifier }, as: :json
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
      post api_v1_devices_pairing_codes_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json
    end

    assert_response :created
    assert_equal device.reload.pairing_code, response.parsed_body["code"]
    assert_operator device.pairing_code_expires_at, :>, 14.minutes.from_now
  end

  test "refuses a code for a paired device_identifier" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), api_key: "existing-key")

    post api_v1_devices_pairing_codes_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :conflict
    assert_equal "device_paired", response.parsed_body["error"]
    assert_nil device.reload.pairing_code
  end

  test "refuses a code for a revoked device_identifier" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :revoked)

    post api_v1_devices_pairing_codes_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :conflict
    assert_equal "device_revoked", response.parsed_body["error"]
    assert_nil device.reload.pairing_code
  end

  test "rejects a request with no X-Device-Identifier header" do
    assert_no_difference "Device.count" do
      post api_v1_devices_pairing_codes_url, as: :json
    end

    assert_response :bad_request
    assert_equal "missing_device_identifier", response.parsed_body["error"]
  end

  test "rejects a request with a blank X-Device-Identifier header" do
    assert_no_difference "Device.count" do
      post api_v1_devices_pairing_codes_url, headers: { "X-Device-Identifier" => " " }, as: :json
    end

    assert_response :bad_request
    assert_equal "missing_device_identifier", response.parsed_body["error"]
  end

  test "sets the device name from the request body" do
    identifier = SecureRandom.uuid

    post api_v1_devices_pairing_codes_url, params: { name: "Shane’s Apple TV" }, headers: { "X-Device-Identifier" => identifier }, as: :json

    assert_response :created
    assert_equal "Shane’s Apple TV", Device.find_by!(device_identifier: identifier).name
  end

  test "updates the device name on reissue" do
    device = Device.create!(device_identifier: SecureRandom.uuid, name: "Apple TV")

    post api_v1_devices_pairing_codes_url, params: { name: "Lobby" }, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :created
    assert_equal "Lobby", device.reload.name
  end

  test "keeps the existing name when a reissue omits it" do
    device = Device.create!(device_identifier: SecureRandom.uuid, name: "Lobby")

    post api_v1_devices_pairing_codes_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_equal "Lobby", device.reload.name
  end

  test "uses the default name when the request sends a blank one" do
    identifier = SecureRandom.uuid

    post api_v1_devices_pairing_codes_url, params: { name: "  " }, headers: { "X-Device-Identifier" => identifier }, as: :json

    assert_response :created
    assert_equal "Apple TV", Device.find_by!(device_identifier: identifier).name
  end
end
