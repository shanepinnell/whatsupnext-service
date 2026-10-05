require "test_helper"

class DeviceClaimsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    @site = sites(:downtown)
    @building = buildings(:tower_one)
    @floor = floors(:penthouse)
    @room = rooms(:summit)
  end

  test "should get new" do
    get new_site_building_floor_room_device_claim_url(@site, @building, @floor, @room)
    assert_response :success
  end

  test "pairs the pending device holding the code to this room" do
    device = Device.create!(device_identifier: SecureRandom.uuid)
    device.issue_pairing_code
    device.save!

    post site_building_floor_room_device_claim_url(@site, @building, @floor, @room), params: { code: device.pairing_code }

    assert_redirected_to site_building_floor_room_url(@site, @building, @floor, @room)
    assert_equal "Device paired.", flash[:notice]
    device.reload
    assert device.paired?
    assert_equal @room, device.room
  end
end
