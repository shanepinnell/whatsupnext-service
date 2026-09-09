require "test_helper"

class SitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    @site = sites(:downtown)
  end

  test "should get index" do
    get sites_url
    assert_response :success
  end

  test "should get new" do
    get new_site_url
    assert_response :success
  end

  test "should create site" do
    assert_difference("Site.count") do
      post sites_url, params: { site: { name: "Riverside Campus" } }
    end

    assert_redirected_to site_url(Site.last)
  end

  test "should show site" do
    get site_url(@site)
    assert_response :success
  end

  test "should get edit" do
    get edit_site_url(@site)
    assert_response :success
  end

  test "should update site" do
    patch site_url(@site), params: { site: { name: @site.name } }
    assert_redirected_to site_url(@site)
  end

  test "should destroy site" do
    assert_difference("Site.count", -1) do
      delete site_url(sites(:midtown))
    end

    assert_redirected_to sites_url
  end

  test "should not destroy site with buildings" do
    assert_no_difference("Site.count") do
      delete site_url(@site)
    end

    assert_redirected_to sites_url
    assert_equal "Cannot delete record because dependent buildings exist", flash[:alert]
  end
end
