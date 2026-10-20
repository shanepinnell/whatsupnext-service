class CalendarSource < ApplicationRecord
  belongs_to :room

  enum :provider, { google: 0, microsoft: 1, ics: 2 }

  serialize :config, coder: JSON
  encrypts :config

  validates :provider, presence: true
  validates :config, presence: true
  validates :room, uniqueness: true
  validate :ics_url_must_be_https, if: :ics?

  def credential_digest
    OpenSSL::HMAC.hexdigest("SHA256", self.class.credential_digest_key, config.sort.to_h.to_json)
  end

  def url
    config.to_h["url"]
  end

  def url=(value)
    self.config = { "url" => value }
  end

  def self.credential_digest_key
    @credential_digest_key ||= Rails.application.key_generator.generate_key("calendar_source credential_digest")
  end

  private
    def ics_url_must_be_https
      uri = URI.parse(url.to_s)
      errors.add(:config, "must be an https URL") unless uri.is_a?(URI::HTTPS) && uri.host.present?
    rescue URI::InvalidURIError
      errors.add(:config, "must be an https URL")
    end
end
