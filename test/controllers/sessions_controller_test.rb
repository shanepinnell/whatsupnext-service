require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "renders a sign-in button posting to the OIDC request phase" do
    get new_session_path

    assert_select "form[action='/auth/openid_connect'][method='post']"
  end
end
