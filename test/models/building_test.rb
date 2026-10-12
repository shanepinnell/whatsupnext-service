require "test_helper"

class BuildingTest < ActiveSupport::TestCase
  test "valid with a name and site" do
    site = Site.new(name: "Downtown Campus")
    building = Building.new(name: "Tower 1", site: site)
    assert building.valid?
  end

  test "invalid without a name" do
    site = Site.new(name: "Downtown Campus")
    building = Building.new(site: site)
    assert_not building.valid?
    assert_includes building.errors[:name], "can't be blank"
  end

  test "invalid without a site" do
    building = Building.new(name: "Tower 1")
    assert_not building.valid?
    assert_includes building.errors[:site], "must exist"
  end

  test "has_many floors" do
    assert_respond_to Building.new, :floors
  end

  test "invalid with a duplicate name within the same site" do
    Building.create!(name: "Executive Tower", site: sites(:downtown))
    dup = Building.new(name: "Executive Tower", site: sites(:downtown))
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "allows the same name in a different site" do
    Building.create!(name: "Executive Tower", site: sites(:downtown))
    other = Building.new(name: "Executive Tower", site: sites(:midtown))
    assert other.valid?
  end
end
