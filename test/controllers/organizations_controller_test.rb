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

  test "renders successfully when no organization exists yet" do
    Room.destroy_all
    Floor.destroy_all
    Building.destroy_all
    Site.destroy_all
    Organization.destroy_all
    sign_in_as users(:one)
    get root_path
    assert_response :success
  end

  test "creates the organization and redirects to root" do
    sign_in_as users(:one)
    assert_difference("Organization.count", 1) do
      post organization_path, params: { organization: { name: "Acme Corp" } }
    end
    assert_redirected_to root_path
  end

  test "renders the edit form for an authenticated user" do
    sign_in_as users(:one)
    get edit_organization_path
    assert_response :success
  end

  test "updates the organization and redirects to root" do
    organization = Organization.first
    sign_in_as users(:one)
    patch organization_path, params: { organization: { name: "New Name" } }
    assert_redirected_to root_path
    assert_equal "New Name", organization.reload.name
  end

  test "updates the organization's support information" do
    organization = Organization.first
    sign_in_as users(:one)
    patch organization_path, params: { organization: { support_information: "Contact support at 555-1234" } }
    assert_redirected_to root_path
    assert_includes organization.reload.support_information.to_plain_text, "Contact support at 555-1234"
  end
end
