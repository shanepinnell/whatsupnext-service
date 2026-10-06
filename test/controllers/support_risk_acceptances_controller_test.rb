require "test_helper"

class SupportRiskAcceptancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test "accepts the device's current support stage as the signed-in admin" do
    device = Device.create!(status: :paired, room: rooms(:summit), model_identifier: "AppleTV5,3")

    travel_to Date.new(2026, 10, 5) do
      post device_support_risk_acceptance_url(device)

      assert_redirected_to device_url(device)
      assert_equal "Risk accepted.", flash[:notice]
      device.reload
      assert device.support_risk_accepted?
      assert_equal users(:one), device.support_risk_accepted_by
    end
  end

  test "refuses to accept a risk for a supported device" do
    device = Device.create!(status: :paired, room: rooms(:summit), model_identifier: "AppleTV14,1")

    post device_support_risk_acceptance_url(device)

    assert_redirected_to device_url(device)
    assert_equal "This Apple TV is supported, so there's no risk to accept.", flash[:alert]
    assert_nil device.reload.support_risk_accepted_stage
  end

  test "requires signing in" do
    sign_out
    device = Device.create!(status: :paired, room: rooms(:summit), model_identifier: "AppleTV5,3")

    post device_support_risk_acceptance_url(device)

    assert_redirected_to new_session_url
    assert_nil device.reload.support_risk_accepted_stage
  end
end
