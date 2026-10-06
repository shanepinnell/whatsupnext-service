require "test_helper"

class Device::SupportCatalogTest < ActiveSupport::TestCase
  setup do
    @catalog = Device::SupportCatalog.new(
      tvos_releases: { 26 => Date.new(2025, 9, 15), 27 => Date.new(2026, 9, 14), 28 => nil },
      models: {
        "AppleTV5,3" => { name: "Apple TV HD", last_tvos: 26 },
        "AppleTV11,1" => { name: "Apple TV 4K (2nd generation)", last_tvos: 27 },
        "AppleTV14,1" => { name: "Apple TV 4K (3rd generation)" }
      }
    )
  end

  test "a model that runs the current tvOS is supported" do
    assert_equal :supported, @catalog.stage_for("AppleTV14,1", on: Date.new(2026, 10, 5))
  end

  test "an unknown model is supported" do
    assert_equal :supported, @catalog.stage_for("AppleTV99,1", on: Date.new(2026, 10, 5))
  end

  test "a device that hasn't reported a model is supported" do
    assert_equal :supported, @catalog.stage_for(nil, on: Date.new(2026, 10, 5))
  end

  test "a model dropped by an announced but unreleased tvOS is losing support" do
    assert_equal :losing_support, @catalog.stage_for("AppleTV11,1", on: Date.new(2026, 10, 5))
  end

  test "a model dropped by a released tvOS is deprecated on the release date" do
    assert_equal :deprecated, @catalog.stage_for("AppleTV5,3", on: Date.new(2026, 9, 14))
  end

  test "a model dropped by a released tvOS is deprecated until 6 months after the release" do
    assert_equal :deprecated, @catalog.stage_for("AppleTV5,3", on: Date.new(2027, 3, 13))
  end

  test "a model dropped by a released tvOS is unsupported from 6 months after the release" do
    assert_equal :unsupported, @catalog.stage_for("AppleTV5,3", on: Date.new(2027, 3, 14))
  end

  test "support ends 6 months after the release of the tvOS that drops the model" do
    assert_equal Date.new(2027, 3, 14), @catalog.support_ends_on("AppleTV5,3")
  end

  test "support end is unknown while the dropping tvOS is unreleased" do
    assert_nil @catalog.support_ends_on("AppleTV11,1")
  end

  test "support never ends for a model on the current tvOS" do
    assert_nil @catalog.support_ends_on("AppleTV14,1")
  end

  test "name_for returns the model's marketing name" do
    assert_equal "Apple TV HD", @catalog.name_for("AppleTV5,3")
  end

  test "name_for is nil for an unknown model" do
    assert_nil @catalog.name_for("AppleTV99,1")
  end

  test "a model on an old tvOS that can run the current one has an update available" do
    assert @catalog.tvos_update_available?("AppleTV14,1", "26.6", on: Date.new(2026, 10, 5))
  end

  test "a model on the current tvOS has no update available" do
    assert_not @catalog.tvos_update_available?("AppleTV14,1", "27.0", on: Date.new(2026, 10, 5))
  end

  test "a model losing support can still update to the current tvOS" do
    assert @catalog.tvos_update_available?("AppleTV11,1", "26.6", on: Date.new(2026, 10, 5))
  end

  test "a model that can't run the current tvOS has no update available" do
    assert_not @catalog.tvos_update_available?("AppleTV5,3", "26.6", on: Date.new(2026, 10, 5))
  end

  test "no update is available before the new tvOS is released" do
    assert_not @catalog.tvos_update_available?("AppleTV14,1", "26.6", on: Date.new(2026, 9, 13))
  end

  test "no update is available when the tvOS version hasn't been reported" do
    assert_not @catalog.tvos_update_available?("AppleTV14,1", nil, on: Date.new(2026, 10, 5))
  end

  test "the default catalog is loaded from config/apple_tv_support.yml" do
    assert_equal Date.new(2026, 9, 14), Device::SupportCatalog.default.support_ends_on("AppleTV5,3") - 6.months
  end
end
