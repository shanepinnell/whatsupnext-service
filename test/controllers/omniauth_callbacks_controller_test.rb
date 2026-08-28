require "test_helper"

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.mock_auth[:openid_connect] = nil
    OmniAuth.config.test_mode = false
  end

  test "JIT-provisions a new User on first successful OIDC login" do
    OmniAuth.config.mock_auth[:openid_connect] = OmniAuth::AuthHash.new(
      provider: "openid_connect",
      uid: "abc123",
      info: { email: "new.user@example.com" }
    )

    assert_difference "User.count", 1 do
      get "/auth/openid_connect/callback"
    end

    user = User.find_by(email_address: "new.user@example.com")
    assert_equal 1, user.sessions.count
    assert cookies[:session_id].present?
  end

  test "signs in the existing User on a repeat OIDC login" do
    user = users(:one)

    OmniAuth.config.mock_auth[:openid_connect] = OmniAuth::AuthHash.new(
      provider: "openid_connect",
      uid: "abc123",
      info: { email: user.email_address }
    )

    assert_no_difference "User.count" do
      get "/auth/openid_connect/callback"
    end

    assert_equal 1, user.reload.sessions.count
    assert cookies[:session_id].present?
  end

  test "redirects to sign in with an alert on OIDC auth failure" do
    OmniAuth.config.mock_auth[:openid_connect] = :invalid_credentials

    get "/auth/openid_connect/callback"
    follow_redirect!

    assert_redirected_to new_session_path
    assert_equal "Sign-in failed: Invalid credentials", flash[:alert]
  end
end
