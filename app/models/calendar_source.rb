class CalendarSource < ApplicationRecord
  belongs_to :room

  enum :provider, { google: 0, microsoft: 1, ics: 2 }

  serialize :config, coder: JSON
  encrypts :config

  validates :provider, presence: true
  validates :config, presence: true
  validates :room, uniqueness: true

  def credential_digest
    OpenSSL::HMAC.hexdigest("SHA256", self.class.credential_digest_key, config.sort.to_h.to_json)
  end

  def self.credential_digest_key
    @credential_digest_key ||= Rails.application.key_generator.generate_key("calendar_source credential_digest")
  end
end
