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
end
