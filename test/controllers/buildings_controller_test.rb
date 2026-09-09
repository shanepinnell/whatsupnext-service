require "test_helper"

class BuildingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    @site = sites(:downtown)
    @building = buildings(:tower_one)
  end

  test "should get index" do
    get site_buildings_url(@site)
    assert_response :success
  end

  test "should get new" do
    get new_site_building_url(@site)
    assert_response :success
  end

  test "should create building" do
    assert_difference("Building.count") do
      post site_buildings_url(@site), params: { building: { name: "Tower 3", timezone: "America/Chicago" } }
    end

    assert_redirected_to site_building_url(@site, Building.last)
  end

  test "should show building" do
    get site_building_url(@site, @building)
    assert_response :success
  end

  test "should get edit" do
    get edit_site_building_url(@site, @building)
    assert_response :success
  end

  test "should update building" do
    patch site_building_url(@site, @building), params: { building: { name: @building.name, timezone: @building.timezone } }
    assert_redirected_to site_building_url(@site, @building)
  end

  test "should destroy building" do
    assert_difference("Building.count", -1) do
      delete site_building_url(@site, buildings(:riverside))
    end

    assert_redirected_to site_buildings_url(@site)
  end

  test "should not destroy building with floors" do
    assert_no_difference("Building.count") do
      delete site_building_url(@site, buildings(:tower_two))
    end

    assert_redirected_to site_buildings_url(@site)
    assert_equal "Cannot delete record because dependent floors exist", flash[:alert]
  end
end
