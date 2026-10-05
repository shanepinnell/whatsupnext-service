require "test_helper"

class RoomPickerTest < ActiveSupport::TestCase
  test "starts at the current room's location" do
    picker = RoomPicker.new(room: rooms(:summit))

    assert_equal [ sites(:downtown), buildings(:tower_one), floors(:penthouse), rooms(:summit) ],
      [ picker.site, picker.building, picker.floor, picker.room ]
  end

  test "does not auto-select a level that has only one option" do
    picker = RoomPicker.new(room: nil, site_id: sites(:downtown).id, building_id: buildings(:tower_one).id)

    assert_nil picker.floor
    assert_nil picker.room
  end

  test "leaves a level empty when none is chosen" do
    picker = RoomPicker.new(room: rooms(:summit), site_id: sites(:downtown).id, building_id: "")

    assert_nil picker.building
    assert_nil picker.floor
    assert_empty picker.floors
  end

  test "ignores a chosen id that isn't under the chosen parent" do
    picker = RoomPicker.new(room: rooms(:summit), site_id: sites(:midtown).id, building_id: buildings(:tower_one).id)

    assert_equal sites(:midtown), picker.site
    assert_nil picker.building
  end

  test "leaves room empty when the chosen floor has no rooms" do
    picker = RoomPicker.new(room: rooms(:summit), site_id: sites(:downtown).id, building_id: buildings(:tower_two).id, floor_id: floors(:mezzanine).id)

    assert_equal floors(:mezzanine), picker.floor
    assert_nil picker.room
  end
end
