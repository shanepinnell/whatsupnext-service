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

  test "claim! raises InvalidPairingCode for an expired code" do
    Device.create!(pairing_code: "123456", pairing_code_expires_at: 1.minute.ago)

    assert_raises(Device::InvalidPairingCode) do
      Device.claim!(code: "123456", room: persisted_room)
    end
  end

  test "claim! raises InvalidPairingCode for a code held by a paired device" do
    room = persisted_room
    Device.create!(status: :paired, room: room, pairing_code: "111111", pairing_code_expires_at: 10.minutes.from_now)

    assert_raises(Device::InvalidPairingCode) { Device.claim!(code: "111111", room: room) }
  end

  test "claim! raises InvalidPairingCode and pairs nothing when two pending devices hold the code" do
    2.times { Device.create!(pairing_code: "123456", pairing_code_expires_at: 10.minutes.from_now) }

    assert_raises(Device::InvalidPairingCode) do
      Device.claim!(code: "123456", room: persisted_room)
    end
    assert_equal 0, Device.paired.count
  end

  test "listed excludes pending devices" do
    room = persisted_room
    Device.create!(device_identifier: SecureRandom.uuid)
    first_paired = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: room)
    second_paired = Device.create!(device_identifier: SecureRandom.uuid, status: :paired, room: room)

    assert_equal [ first_paired, second_paired ].sort, Device.listed.sort
  end

  test "listed sorts by name" do
    room = persisted_room
    lobby = Device.create!(status: :paired, room: room, name: "Lobby")
    annex = Device.create!(status: :paired, room: room, name: "Annex")
    default = Device.create!(status: :paired, room: room)

    assert_equal [ annex, default, lobby ], Device.listed.to_a
  end

  test "defaults name to Apple TV" do
    assert_equal "Apple TV", Device.new.name
  end

  test "invalid with a blank name" do
    device = Device.new(name: " ")
    assert_not device.valid?
    assert_includes device.errors[:name], "can't be blank"
  end

  test "status is either pending or paired" do
    assert_equal %w[ pending paired ], Device.statuses.keys
  end

  test "network is ethernet, wifi or other" do
    assert_equal %w[ ethernet wifi other ], Device.networks.keys
  end

  test "authenticated_by finds the device with that api key" do
    device = Device.create!(api_key: "device-key")
    assert_equal device, Device.authenticated_by("device-key")
  end

  test "authenticated_by returns nil for an unknown api key" do
    Device.create!(api_key: "device-key")
    assert_nil Device.authenticated_by("other-key")
  end

  test "hardware_name is the catalog's marketing name" do
    assert_equal "Apple TV HD", Device.new(model_identifier: "AppleTV5,3").hardware_name
  end

  test "hardware_name falls back to the model identifier for an unknown model" do
    assert_equal "AppleTV99,1", Device.new(model_identifier: "AppleTV99,1").hardware_name
  end

  test "support_ends_on comes from the default catalog" do
    assert_equal Date.new(2027, 3, 14), Device.new(model_identifier: "AppleTV5,3").support_ends_on
  end

  test "needing_support_attention lists paired devices that aren't supported" do
    room = persisted_room
    old = Device.create!(status: :paired, room: room, model_identifier: "AppleTV5,3")
    Device.create!(status: :paired, room: room, model_identifier: "AppleTV14,1")
    Device.create!(model_identifier: "AppleTV5,3")

    travel_to Date.new(2026, 10, 5) do
      assert_equal [ old ], Device.needing_support_attention
    end
  end

  test "support_stage uses the default catalog and today's date" do
    travel_to Date.new(2027, 3, 14) do
      assert_equal :unsupported, Device.new(model_identifier: "AppleTV5,3").support_stage
    end
  end
end
