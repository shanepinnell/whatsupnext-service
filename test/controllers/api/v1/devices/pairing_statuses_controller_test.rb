require "test_helper"

class Api::V1::Devices::PairingStatusesControllerTest < ActionDispatch::IntegrationTest
  test "reports pending until the device is claimed" do
    device = Device.create!(device_identifier: SecureRandom.uuid)

    get api_v1_devices_pairing_status_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :success
    assert_equal({ "status" => "pending" }, response.parsed_body)
  end

  test "delivers the api key and room on the first poll after claiming" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit))

    get api_v1_devices_pairing_status_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal "paired", body["status"]
    assert_equal({ "name" => rooms(:summit).name }, body["room"])
    assert_equal device, Device.authenticated_by(body["api_key"])
  end

  test "never delivers the api key a second time" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit))
    get api_v1_devices_pairing_status_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    get api_v1_devices_pairing_status_url, headers: { "X-Device-Identifier" => device.device_identifier }, as: :json

    assert_response :success
    assert_equal({ "status" => "paired", "room" => { "name" => rooms(:summit).name } }, response.parsed_body)
  end

  test "rejects a request without a device identifier" do
    get api_v1_devices_pairing_status_url, as: :json

    assert_response :bad_request
    assert_equal "missing_device_identifier", response.parsed_body["error"]
  end

  test "reports an unknown device identifier" do
    get api_v1_devices_pairing_status_url, headers: { "X-Device-Identifier" => SecureRandom.uuid }, as: :json

    assert_response :not_found
    assert_equal "unknown_device", response.parsed_body["error"]
  end
end
