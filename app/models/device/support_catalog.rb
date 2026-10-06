class Device::SupportCatalog
  DEPRECATION_PERIOD = 6.months

  def self.default
    @default ||= begin
      data = YAML.load_file(Rails.root.join("config/apple_tv_support.yml"), permitted_classes: [ Date ])
      new(tvos_releases: data["tvos_releases"], models: data["models"].transform_values(&:symbolize_keys))
    end
  end

  def initialize(tvos_releases:, models:)
    @tvos_releases = tvos_releases
    @models = models
  end

  def stage_for(model_identifier, on:)
    return :supported unless dropping_major(model_identifier)

    released_on = dropping_release_date(model_identifier)
    if released_on.nil? || on < released_on then :losing_support
    elsif on < released_on + DEPRECATION_PERIOD then :deprecated
    else :unsupported
    end
  end

  def support_ends_on(model_identifier)
    released_on = dropping_release_date(model_identifier)
    released_on + DEPRECATION_PERIOD if released_on
  end

  private
    def dropping_major(model_identifier)
      last_tvos = @models.dig(model_identifier, :last_tvos)
      last_tvos + 1 if last_tvos && @tvos_releases.key?(last_tvos + 1)
    end

    def dropping_release_date(model_identifier)
      major = dropping_major(model_identifier)
      @tvos_releases[major] if major
    end
end
