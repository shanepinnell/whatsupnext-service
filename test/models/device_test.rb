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

  test "valid when paired with a room" do
    device = Device.new(status: :paired, room: persisted_room)
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

  test "issue_pairing_code sets a 6-digit code expiring in 15 minutes" do
    freeze_time do
      device = Device.new
      device.issue_pairing_code
      assert_match(/\A[1-9]\d{5}\z/, device.pairing_code)
      assert_equal 15.minutes.from_now, device.pairing_code_expires_at
    end
  end

  test "issue_pairing_code avoids codes already held by an unexpired device" do
    Device.create!(pairing_code: "123456", pairing_code_expires_at: 10.minutes.from_now)
    SecureRandom.stub(:random_number, ->(_) { @calls = (@calls || 0) + 1; @calls == 1 ? 123456 : 654321 }) do
      device = Device.new
      device.issue_pairing_code
      assert_equal "654321", device.pairing_code
    end
  end

  test "claim! pairs the pending device holding an unexpired code to a room" do
    room = persisted_room
    device = Device.create!(device_identifier: SecureRandom.uuid)
    device.issue_pairing_code
    device.save!

    freeze_time do
      claimed = Device.claim!(code: device.pairing_code, room: room)

      assert_equal device, claimed
      device.reload
      assert device.paired?
      assert_equal room, device.room
      assert_equal Time.current, device.paired_at
      assert_nil device.pairing_code
      assert_nil device.pairing_code_expires_at
      assert_nil device.api_key_digest
    end
  end

  test "claim! raises InvalidPairingCode for a code no device holds" do
    assert_raises(Device::InvalidPairingCode) do
      Device.claim!(code: "999999", room: persisted_room)
    end
  end
end
