require "test_helper"

class CalendarSourceTest < ActiveSupport::TestCase
  def persisted_room
    floor = Floor.create!(name: "1", building: buildings(:tower_one))
    Room.create!(name: "Everest", floor: floor)
  end

  test "valid with a provider, config, and room" do
    calendar_source = CalendarSource.new(provider: :google, config: { "calendar_id" => "abc" }, room: persisted_room)
    assert calendar_source.valid?
  end

  test "invalid without a provider" do
    calendar_source = CalendarSource.new(config: { "calendar_id" => "abc" }, room: persisted_room)
    assert_not calendar_source.valid?
    assert_includes calendar_source.errors[:provider], "can't be blank"
  end

  test "invalid without config" do
    calendar_source = CalendarSource.new(provider: :google, room: persisted_room)
    assert_not calendar_source.valid?
    assert_includes calendar_source.errors[:config], "can't be blank"
  end

  test "invalid without a room" do
    calendar_source = CalendarSource.new(provider: :google, config: { "calendar_id" => "abc" })
    assert_not calendar_source.valid?
    assert_includes calendar_source.errors[:room], "must exist"
  end

  test "invalid with a duplicate room" do
    room = persisted_room
    CalendarSource.create!(provider: :google, config: { "calendar_id" => "abc" }, room: room)
    dup = CalendarSource.new(provider: :microsoft, config: { "calendar_id" => "xyz" }, room: room)
    assert_not dup.valid?
    assert_includes dup.errors[:room], "has already been taken"
  end

  test "credential_digest is the same for the same config regardless of key order" do
    a = CalendarSource.new(provider: :google, config: { "calendar_id" => "abc", "refresh_token" => "r1" })
    b = CalendarSource.new(provider: :google, config: { "refresh_token" => "r1", "calendar_id" => "abc" })
    assert_equal a.credential_digest, b.credential_digest
  end

  test "credential_digest changes when config changes" do
    calendar_source = CalendarSource.new(provider: :google, config: { "calendar_id" => "abc", "refresh_token" => "r1" })
    before = calendar_source.credential_digest
    calendar_source.config = { "calendar_id" => "abc", "refresh_token" => "r2" }
    assert_not_equal before, calendar_source.credential_digest
  end

  test "credential_digest is a keyed HMAC, not a plain hash of config" do
    config = { "calendar_id" => "abc", "refresh_token" => "r1" }
    calendar_source = CalendarSource.new(provider: :google, config: config)
    assert_match(/\A\h{64}\z/, calendar_source.credential_digest)
    assert_not_equal Digest::SHA256.hexdigest(config.sort.to_h.to_json), calendar_source.credential_digest
  end

  test "encrypts config" do
    assert_includes CalendarSource.encrypted_attributes, :config
  end
end
