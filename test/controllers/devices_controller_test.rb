require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "should get index" do
    get devices_url
    assert_response :success
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

  test "should get edit" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), paired_at: 1.day.ago)

    get edit_device_url(device)
    assert_response :success
  end

  test "should move a device to another room" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), paired_at: 1.day.ago)
    other_room = floors(:penthouse).rooms.create!(name: "Base Camp")

    patch device_url(device), params: { device: { room_id: other_room.id } }

    assert_redirected_to device_url(device)
    assert_equal other_room, device.reload.room
  end

  test "update ignores the name" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), paired_at: 1.day.ago, name: "Lobby")

    patch device_url(device), params: { device: { room_id: device.room_id, name: "Hacked" } }

    assert_equal "Lobby", device.reload.name
  end

  test "should delete a device" do
    device = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: rooms(:summit), paired_at: 1.day.ago)

    assert_difference("Device.count", -1) do
      delete device_url(device)
    end

    assert_redirected_to devices_url
    assert_equal "Device deleted.", flash[:notice]
  end
end
