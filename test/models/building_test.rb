require "test_helper"

class BuildingTest < ActiveSupport::TestCase
  test "valid with a name, timezone, and site" do
    site = Site.new(name: "Downtown Campus")
    building = Building.new(name: "Tower 1", timezone: "America/Chicago", site: site)
    assert building.valid?
  end

  test "invalid without a name" do
    site = Site.new(name: "Downtown Campus")
    building = Building.new(timezone: "America/Chicago", site: site)
    assert_not building.valid?
    assert_includes building.errors[:name], "can't be blank"
  end

  test "invalid without a timezone" do
    site = Site.new(name: "Downtown Campus")
    building = Building.new(name: "Tower 1", site: site)
    assert_not building.valid?
    assert_includes building.errors[:timezone], "can't be blank"
  end

  test "invalid without a site" do
    building = Building.new(name: "Tower 1", timezone: "America/Chicago")
    assert_not building.valid?
    assert_includes building.errors[:site], "must exist"
  end

  test "has_many floors" do
    assert_respond_to Building.new, :floors
  end

  test "invalid with a duplicate name within the same site" do
    Building.create!(name: "Executive Tower", timezone: "America/Chicago", site: sites(:downtown))
    dup = Building.new(name: "Executive Tower", timezone: "America/Chicago", site: sites(:downtown))
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "allows the same name in a different site" do
    Building.create!(name: "Executive Tower", timezone: "America/Chicago", site: sites(:downtown))
    other = Building.new(name: "Executive Tower", timezone: "America/Chicago", site: sites(:midtown))
    assert other.valid?
  end
end
