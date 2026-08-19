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

  test "credential_version defaults to 0" do
    calendar_source = CalendarSource.create!(provider: :google, config: { "calendar_id" => "abc" }, room: persisted_room)
    assert_equal 0, calendar_source.credential_version
  end

  test "credential_version bumps when config changes" do
    calendar_source = CalendarSource.create!(provider: :google, config: { "calendar_id" => "abc" }, room: persisted_room)
    calendar_source.update!(config: { "calendar_id" => "xyz" })
    assert_equal 1, calendar_source.credential_version
  end

  test "credential_version does not bump when config is unchanged" do
    calendar_source = CalendarSource.create!(provider: :google, config: { "calendar_id" => "abc" }, room: persisted_room)
    calendar_source.update!(webhook_subscription_id: "sub_123")
    assert_equal 0, calendar_source.credential_version
  end

  test "encrypts config" do
    assert_includes CalendarSource.encrypted_attributes, :config
  end
end
