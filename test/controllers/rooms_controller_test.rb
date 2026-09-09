require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    @site = sites(:downtown)
    @building = buildings(:tower_one)
    @floor = floors(:penthouse)
    @room = rooms(:summit)
  end

  test "should get index" do
    get site_building_floor_rooms_url(@site, @building, @floor)
    assert_response :success
  end

  test "should get new" do
    get new_site_building_floor_room_url(@site, @building, @floor)
    assert_response :success
  end

  test "should create room" do
    assert_difference("Room.count") do
      post site_building_floor_rooms_url(@site, @building, @floor), params: { room: { name: "Base Camp" } }
    end

    assert_redirected_to site_building_floor_room_url(@site, @building, @floor, Room.last)
  end

  test "should show room" do
    get site_building_floor_room_url(@site, @building, @floor, @room)
    assert_response :success
  end

  test "should get edit" do
    get edit_site_building_floor_room_url(@site, @building, @floor, @room)
    assert_response :success
  end

  test "should update room" do
    patch site_building_floor_room_url(@site, @building, @floor, @room), params: { room: { name: @room.name } }
    assert_redirected_to site_building_floor_room_url(@site, @building, @floor, @room)
  end

  test "should destroy room" do
    assert_difference("Room.count", -1) do
      delete site_building_floor_room_url(@site, @building, @floor, @room)
    end

    assert_redirected_to site_building_floor_rooms_url(@site, @building, @floor)
  end

  test "should not destroy room with a calendar source" do
    CalendarSource.create!(provider: :google, config: { "calendar_id" => "abc" }, room: @room)

    assert_no_difference("Room.count") do
      delete site_building_floor_room_url(@site, @building, @floor, @room)
    end

    assert_redirected_to site_building_floor_rooms_url(@site, @building, @floor)
    assert_equal "Cannot delete record because a dependent calendar source exists", flash[:alert]
  end

  test "should not destroy room with a device" do
    Device.create!(room: @room)

    assert_no_difference("Room.count") do
      delete site_building_floor_room_url(@site, @building, @floor, @room)
    end

    assert_redirected_to site_building_floor_rooms_url(@site, @building, @floor)
    assert_equal "Cannot delete record because dependent devices exist", flash[:alert]
  end
end
