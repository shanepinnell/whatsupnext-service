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

  test "re-renders the form with 422 and pairs nothing for an invalid code" do
    device = Device.create!(device_identifier: SecureRandom.uuid)
    device.issue_pairing_code
    device.save!
    wrong_code = device.pairing_code == "999999" ? "999998" : "999999"

    post site_building_floor_room_device_claim_url(@site, @building, @floor, @room), params: { code: wrong_code }

    assert_response :unprocessable_entity
    assert_equal "That code isn't valid or has expired. Check the code on the TV and try again.", flash[:alert]
    assert device.reload.pending?
  end
end
