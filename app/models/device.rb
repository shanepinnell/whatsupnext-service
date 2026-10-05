require "digest"

class Device < ApplicationRecord
  enum :status, { pending: 0, paired: 1, revoked: 2 }

  PAIRING_CODE_TTL = 15.minutes

  belongs_to :room, optional: true

  attr_reader :api_key

  validates :device_identifier, uniqueness: true, allow_nil: true
  validates :mdm_device_id, uniqueness: true, allow_nil: true
  validates :room, presence: true, if: :paired?
  validate :api_key_must_be_present_when_paired

  def api_key=(plaintext)
    @api_key = plaintext
    self.api_key_digest = plaintext.present? ? Digest::SHA256.hexdigest(plaintext) : nil
  end

  def authenticate_api_key(plaintext)
    return false if api_key_digest.blank?
    ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(plaintext.to_s), api_key_digest)
  end

  def issue_pairing_code
    self.pairing_code = SecureRandom.random_number(100_000..999_999).to_s
    self.pairing_code_expires_at = PAIRING_CODE_TTL.from_now
  end

  private

  def api_key_must_be_present_when_paired
    errors.add(:api_key, :blank) if paired? && api_key_digest.blank?
  end
end
