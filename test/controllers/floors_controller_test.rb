require "test_helper"

class FloorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    @site = sites(:downtown)
    @building = buildings(:tower_one)
    @floor = floors(:penthouse)
  end

  test "should get index" do
    get site_building_floors_url(@site, @building)
    assert_response :success
  end

  test "should get new" do
    get new_site_building_floor_url(@site, @building)
    assert_response :success
  end

  test "should create floor" do
    assert_difference("Floor.count") do
      post site_building_floors_url(@site, @building), params: { floor: { name: "Rooftop" } }
    end

    assert_redirected_to site_building_floor_url(@site, @building, Floor.last)
  end

  test "should show floor" do
    get site_building_floor_url(@site, @building, @floor)
    assert_response :success
  end

  test "should get edit" do
    get edit_site_building_floor_url(@site, @building, @floor)
    assert_response :success
  end

  test "should update floor" do
    patch site_building_floor_url(@site, @building, @floor), params: { floor: { name: @floor.name } }
    assert_redirected_to site_building_floor_url(@site, @building, @floor)
  end

  test "should destroy floor" do
    building_two = buildings(:tower_two)
    floor_without_rooms = floors(:mezzanine)

    assert_difference("Floor.count", -1) do
      delete site_building_floor_url(@site, building_two, floor_without_rooms)
    end

    assert_redirected_to site_building_floors_url(@site, building_two)
  end

  test "should not destroy floor with rooms" do
    assert_no_difference("Floor.count") do
      delete site_building_floor_url(@site, @building, @floor)
    end

    assert_redirected_to site_building_floors_url(@site, @building)
    assert_equal "Cannot delete record because dependent rooms exist", flash[:alert]
  end
end
