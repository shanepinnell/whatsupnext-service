require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "valid with a name and floor" do
    floor = Floor.create!(name: "1", building: buildings(:tower_one))
    room = Room.new(name: "Everest", floor: floor)
    assert room.valid?
  end

  test "invalid without a name" do
    floor = Floor.create!(name: "1", building: buildings(:tower_one))
    room = Room.new(floor: floor)
    assert_not room.valid?
    assert_includes room.errors[:name], "can't be blank"
  end

  test "invalid without a floor" do
    room = Room.new(name: "Everest")
    assert_not room.valid?
    assert_includes room.errors[:floor], "must exist"
  end

  test "invalid with a duplicate name on the same floor" do
    floor = Floor.create!(name: "1", building: buildings(:tower_one))
    Room.create!(name: "Everest", floor: floor)
    dup = Room.new(name: "Everest", floor: floor)
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "allows the same name on a different floor" do
    floor_one = Floor.create!(name: "1", building: buildings(:tower_one))
    floor_two = Floor.create!(name: "2", building: buildings(:tower_one))
    Room.create!(name: "Everest", floor: floor_one)
    other = Room.new(name: "Everest", floor: floor_two)
    assert other.valid?
  end

  test "has_one_attached background_image" do
    assert_respond_to Room.new, :background_image
  end

  test "valid with a 1920x1080 background image" do
    assert room_with_background("background_1920x1080.png").valid?
  end

  test "valid with a 3840x2160 background image" do
    assert room_with_background("background_3840x2160.png").valid?
  end

  test "valid with a WebP background image" do
    assert room_with_background("background_1920x1080.webp", content_type: "image/webp").valid?
  end

  test "invalid with a background image smaller than 1920x1080" do
    assert_not room_with_background("background_1280x720.png").valid?
  end

  test "invalid with a background image larger than 3840x2160" do
    assert_not room_with_background("background_7680x4320.png").valid?
  end

  test "invalid with a background image that isn't 16:9" do
    assert_not room_with_background("background_2048x1536.png").valid?
  end

  test "invalid with a background image that isn't an image" do
    assert_not room_with_background("not_an_image.txt", content_type: "text/plain").valid?
  end

  test "creates its calendar source through nested attributes" do
    room = rooms(:summit)
    room.update!(calendar_source_attributes: { provider: "ics", url: "https://calendar.example.com/private/abc.ics" })
    assert_equal "https://calendar.example.com/private/abc.ics", room.reload.calendar_source.url
  end

  test "updates its existing calendar source rather than replacing it" do
    room = rooms(:summit)
    calendar_source = CalendarSource.create!(room: room, provider: :google, config: { "calendar_id" => "abc", "refresh_token" => "r1" })
    room.update!(calendar_source_attributes: { provider: "ics", url: "https://calendar.example.com/private/abc.ics" })
    assert_equal calendar_source.id, room.reload.calendar_source.id
    assert_equal({ "url" => "https://calendar.example.com/private/abc.ics" }, room.calendar_source.config)
  end

  test "removes its calendar source through nested attributes" do
    room = rooms(:summit)
    CalendarSource.create!(room: room, provider: :ics, url: "https://calendar.example.com/private/abc.ics")
    room.update!(calendar_source_attributes: { _destroy: "1" })
    assert_nil room.reload.calendar_source
  end

  test "ignores a blank calendar source when it has none" do
    room = rooms(:summit)
    room.update!(calendar_source_attributes: { provider: "ics", url: "" })
    assert_nil room.reload.calendar_source
  end

  test "invalid with an invalid calendar source" do
    room = rooms(:summit)
    room.calendar_source_attributes = { provider: "ics", url: "http://calendar.example.com/private/abc.ics" }
    assert_not room.valid?
    assert_includes room.errors[:"calendar_source.config"], "must be an https URL"
  end

  private
    def room_with_background(filename, content_type: "image/png")
      floor = Floor.create!(name: "1", building: buildings(:tower_one))
      Room.new(name: "Everest", floor: floor).tap do |room|
        room.background_image.attach(io: file_fixture(filename).open, filename: filename, content_type: content_type)
      end
    end
end
