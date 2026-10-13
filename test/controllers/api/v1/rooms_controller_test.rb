require "test_helper"

class Api::V1::RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), api_key: "device-key")
  end

  test "returns the device's room name and its site's timezone" do
    get api_v1_device_room_url, headers: auth_headers, as: :json

    assert_response :success
    assert_equal({ "room" => { "name" => rooms(:summit).name, "timezone" => "America/Chicago", "background_image_url" => nil, "calendar_source" => nil } }, response.parsed_body)
  end

  test "includes the calendar source provider and credential digest, never the config" do
    calendar_source = CalendarSource.create!(room: rooms(:summit), provider: :google, config: { "calendar_id" => "abc", "refresh_token" => "r1" })

    get api_v1_device_room_url, headers: auth_headers, as: :json

    assert_response :success
    assert_equal({ "provider" => "google", "credential_digest" => calendar_source.credential_digest }, response.parsed_body.dig("room", "calendar_source"))
  end

  test "returns the room's background image url" do
    rooms(:summit).background_image.attach(io: file_fixture("background_1920x1080.png").open, filename: "background_1920x1080.png", content_type: "image/png")

    get api_v1_device_room_url, headers: auth_headers, as: :json

    assert_response :success
    assert_equal rails_blob_url(rooms(:summit).background_image), response.parsed_body.dig("room", "background_image_url")
  end

  test "records when the device was last seen" do
    freeze_time do
      get api_v1_device_room_url, headers: auth_headers, as: :json

      assert_equal Time.current, @device.reload.last_seen_at
    end
  end

  test "rejects a request without an api key" do
    get api_v1_device_room_url, as: :json

    assert_response :unauthorized
    assert_equal "invalid_api_key", response.parsed_body["error"]
  end

  test "rejects an unknown api key" do
    get api_v1_device_room_url, headers: { "Authorization" => "Bearer wrong-key" }, as: :json

    assert_response :unauthorized
    assert_equal "invalid_api_key", response.parsed_body["error"]
  end

  test "blocks an unsupported device whose risk hasn't been accepted" do
    @device.update!(model_identifier: "AppleTV5,3")

    travel_to Date.new(2027, 4, 1) do
      get api_v1_device_room_url, headers: auth_headers, as: :json
    end

    assert_response :forbidden
    assert_equal({ "error" => "unsupported_device" }, response.parsed_body)
  end

  test "records when a blocked device was last seen" do
    @device.update!(model_identifier: "AppleTV5,3")

    travel_to Time.zone.local(2027, 4, 1, 12) do
      get api_v1_device_room_url, headers: auth_headers, as: :json

      assert_equal Time.current, @device.reload.last_seen_at
    end
  end

  test "serves an unsupported device whose risk has been accepted" do
    @device.update!(model_identifier: "AppleTV5,3", support_risk_accepted_stage: "unsupported")

    travel_to Date.new(2027, 4, 1) do
      get api_v1_device_room_url, headers: auth_headers, as: :json
    end

    assert_response :success
  end

  test "blocks an unsupported device whose risk was only accepted at an earlier stage" do
    @device.update!(model_identifier: "AppleTV5,3", support_risk_accepted_stage: "deprecated")

    travel_to Date.new(2027, 4, 1) do
      get api_v1_device_room_url, headers: auth_headers, as: :json
    end

    assert_response :forbidden
  end

  test "serves a deprecated device without blocking" do
    @device.update!(model_identifier: "AppleTV5,3")

    travel_to Date.new(2026, 10, 5) do
      get api_v1_device_room_url, headers: auth_headers, as: :json
    end

    assert_response :success
  end

  private
    def auth_headers
      { "Authorization" => "Bearer device-key" }
    end
end
