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
end
