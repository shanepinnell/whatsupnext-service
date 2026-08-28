require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated visitors to sign in" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "renders the organization for an authenticated user" do
    sign_in_as users(:one)
    get root_path
    assert_response :success
  end
end
