require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "valid with a name" do
    organization = Organization.new(name: "Acme Corp")
    assert organization.valid?
  end
end
