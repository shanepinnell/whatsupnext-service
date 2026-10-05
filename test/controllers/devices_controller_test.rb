require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "should show a paired device with a room" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), paired_at: 1.day.ago)

    get device_url(device)
    assert_response :success
  end

  test "should show a device with no room" do
    device = Device.create!(device_identifier: SecureRandom.uuid)

    get device_url(device)
    assert_response :success
  end

  test "returns 404 for an unknown device" do
    get device_url(id: 0)
    assert_response :not_found
  end
end
