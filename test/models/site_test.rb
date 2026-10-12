require "test_helper"

class SiteTest < ActiveSupport::TestCase
  test "valid with a name, timezone, and organization" do
    organization = Organization.new(name: "Acme Corp")
    site = Site.new(name: "Downtown Campus", timezone: "America/Chicago", organization: organization)
    assert site.valid?
  end

  test "invalid without a name" do
    organization = Organization.new(name: "Acme Corp")
    site = Site.new(organization: organization)
    assert_not site.valid?
    assert_includes site.errors[:name], "can't be blank"
  end

  test "invalid without a timezone" do
    organization = Organization.new(name: "Acme Corp")
    site = Site.new(name: "Downtown Campus", organization: organization)
    assert_not site.valid?
    assert_includes site.errors[:timezone], "can't be blank"
  end

  test "invalid with an unrecognized timezone" do
    organization = Organization.new(name: "Acme Corp")
    site = Site.new(name: "Downtown Campus", timezone: "Not/AZone", organization: organization)
    assert_not site.valid?
    assert_includes site.errors[:timezone], "is not included in the list"
  end

  test "invalid without an organization" do
    site = Site.new(name: "Downtown Campus")
    assert_not site.valid?
    assert_includes site.errors[:organization], "must exist"
  end

  test "has_many buildings" do
    assert_respond_to Site.new, :buildings
  end

  test "invalid with a duplicate name within the same organization" do
    Site.create!(name: "Riverside Campus", timezone: "America/Chicago", organization: organizations(:acme))
    dup = Site.new(name: "Riverside Campus", timezone: "America/Chicago", organization: organizations(:acme))
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "allows the same name in a different organization" do
    Site.create!(name: "Riverside Campus", timezone: "America/Chicago", organization: organizations(:acme))
    other = Site.new(name: "Riverside Campus", timezone: "America/Chicago", organization: organizations(:globex))
    assert other.valid?
  end
end
