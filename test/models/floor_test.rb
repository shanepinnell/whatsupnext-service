require "test_helper"

class FloorTest < ActiveSupport::TestCase
  test "valid with a name and building" do
    floor = Floor.new(name: "1", building: buildings(:tower_one))
    assert floor.valid?
  end

  test "invalid without a name" do
    building = Building.new(name: "Tower 1", timezone: "America/Chicago")
    floor = Floor.new(building: building)
    assert_not floor.valid?
    assert_includes floor.errors[:name], "can't be blank"
  end

  test "invalid without a building" do
    floor = Floor.new(name: "1")
    assert_not floor.valid?
    assert_includes floor.errors[:building], "must exist"
  end

  test "invalid with a duplicate name within the same building" do
    Floor.create!(name: "3", building: buildings(:tower_one))
    dup = Floor.new(name: "3", building: buildings(:tower_one))
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "allows the same name in a different building" do
    Floor.create!(name: "3", building: buildings(:tower_one))
    other = Floor.new(name: "3", building: buildings(:tower_two))
    assert other.valid?
  end

  test "has_many rooms" do
    assert_respond_to Floor.new, :rooms
  end

  test "positioned on building" do
    assert_respond_to Floor.new, :prior_position
  end
end
