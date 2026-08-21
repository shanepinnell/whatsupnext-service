require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  def persisted_room
    floor = Floor.create!(name: "1", building: buildings(:tower_one))
    Room.create!(name: "Everest", floor: floor)
  end

  test "valid with no attributes set" do
    device = Device.new
    assert device.valid?
  end

  test "defaults to pending status" do
    device = Device.create!
    assert_predicate device, "pending?"
  end

  test "valid without a room" do
    device = Device.new
    assert device.valid?
  end

  test "valid with a room" do
    device = Device.new(room: persisted_room)
    assert device.valid?
  end

  test "invalid when paired without a room" do
    device = Device.new(status: :paired, api_key: "plaintext-token")
    assert_not device.valid?
    assert_includes device.errors[:room], "can't be blank"
  end

  test "invalid when paired without an api_key" do
    device = Device.new(status: :paired, room: persisted_room)
    assert_not device.valid?
    assert_includes device.errors[:api_key], "can't be blank"
  end

  test "valid when paired with a room and api_key" do
    device = Device.new(status: :paired, room: persisted_room, api_key: "plaintext-token")
    assert device.valid?
  end

  test "valid with a device_identifier" do
    device = Device.new(device_identifier: SecureRandom.uuid)
    assert device.valid?
  end

  test "invalid with a duplicate device_identifier" do
    Device.create!(device_identifier: "dup-id")
    dup = Device.new(device_identifier: "dup-id")
    assert_not dup.valid?
    assert_includes dup.errors[:device_identifier], "has already been taken"
  end

  test "allows multiple devices with no device_identifier" do
    Device.create!
    other = Device.new
    assert other.valid?
  end

  test "invalid with a duplicate mdm_device_id" do
    Device.create!(mdm_device_id: "serial-123")
    dup = Device.new(mdm_device_id: "serial-123")
    assert_not dup.valid?
    assert_includes dup.errors[:mdm_device_id], "has already been taken"
  end

  test "allows multiple devices with no mdm_device_id" do
    Device.create!
    other = Device.new
    assert other.valid?
  end

  test "api_key is stored as a digest, not plaintext" do
    device = Device.create!(api_key: "plaintext-token")
    assert_not_nil device.api_key_digest
    assert_not_equal "plaintext-token", device.api_key_digest
  end

  test "authenticates a matching api_key" do
    device = Device.create!(api_key: "plaintext-token")
    assert device.authenticate_api_key("plaintext-token")
  end

  test "does not authenticate a non-matching api_key" do
    device = Device.create!(api_key: "plaintext-token")
    assert_not device.authenticate_api_key("wrong-token")
  end

  test "does not authenticate when no api_key is set" do
    device = Device.create!
    assert_not device.authenticate_api_key("anything")
  end
end
