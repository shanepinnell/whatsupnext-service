require "test_helper"

class Api::V1::CalendarSourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), api_key: "device-key")
  end

  test "returns the room's calendar source with its config" do
    calendar_source = CalendarSource.create!(room: rooms(:summit), provider: :google, config: { "calendar_id" => "abc", "refresh_token" => "r1" })

    get api_v1_device_room_calendar_source_url, headers: auth_headers, as: :json

    assert_response :success
    assert_equal({ "provider" => "google", "credential_digest" => calendar_source.credential_digest, "config" => { "calendar_id" => "abc", "refresh_token" => "r1" } }, response.parsed_body)
  end

  test "returns not found when the room has no calendar source" do
    get api_v1_device_room_calendar_source_url, headers: auth_headers, as: :json

    assert_response :not_found
    assert_equal({ "error" => "no_calendar_source" }, response.parsed_body)
  end

  test "rejects a request without an api key" do
    get api_v1_device_room_calendar_source_url, as: :json

    assert_response :unauthorized
    assert_equal "invalid_api_key", response.parsed_body["error"]
  end

  test "rejects an unknown api key" do
    get api_v1_device_room_calendar_source_url, headers: { "Authorization" => "Bearer wrong-key" }, as: :json

    assert_response :unauthorized
    assert_equal "invalid_api_key", response.parsed_body["error"]
  end

  test "blocks an unsupported device whose risk hasn't been accepted" do
    @device.update!(model_identifier: "AppleTV5,3")
    CalendarSource.create!(room: rooms(:summit), provider: :google, config: { "calendar_id" => "abc", "refresh_token" => "r1" })

    travel_to Date.new(2027, 4, 1) do
      get api_v1_device_room_calendar_source_url, headers: auth_headers, as: :json
    end

    assert_response :forbidden
    assert_equal({ "error" => "unsupported_device" }, response.parsed_body)
  end

  test "does not record when the device was last seen" do
    get api_v1_device_room_calendar_source_url, headers: auth_headers, as: :json

    assert_nil @device.reload.last_seen_at
  end

  private
    def auth_headers
      { "Authorization" => "Bearer device-key" }
    end
end
