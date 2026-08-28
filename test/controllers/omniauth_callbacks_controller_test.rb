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
end
