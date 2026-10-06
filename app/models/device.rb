require "digest"

class Device < ApplicationRecord
  enum :status, { pending: 0, paired: 1 }
  enum :network, { ethernet: 0, wifi: 1, other: 2 }, prefix: true, validate: { allow_nil: true }

  PAIRING_CODE_TTL = 15.minutes
  DEFAULT_NAME = "Apple TV"

  class InvalidPairingCode < StandardError; end

  belongs_to :room, optional: true

  scope :listed, -> { paired.order(:name) }

  attr_reader :api_key

  validates :device_identifier, uniqueness: true, allow_nil: true
  validates :mdm_device_id, uniqueness: true, allow_nil: true
  validates :room, presence: true, if: :paired?
  validates :name, presence: true

  def api_key=(plaintext)
    @api_key = plaintext
    self.api_key_digest = plaintext.present? ? Digest::SHA256.hexdigest(plaintext) : nil
  end

  def authenticate_api_key(plaintext)
    return false if api_key_digest.blank?
    ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(plaintext.to_s), api_key_digest)
  end

  def self.authenticated_by(api_key)
    find_by(api_key_digest: Digest::SHA256.hexdigest(api_key)) if api_key.present?
  end

  def support_stage
    SupportCatalog.default.stage_for(model_identifier, on: Date.current)
  end

  def issue_pairing_code
    self.pairing_code = loop do
      code = SecureRandom.random_number(100_000..999_999).to_s
      break code unless Device.where(pairing_code: code).where("pairing_code_expires_at > ?", Time.current).exists?
    end
    self.pairing_code_expires_at = PAIRING_CODE_TTL.from_now
  end

  def self.claim!(code:, room:)
    device = pending.where(pairing_code: code).where("pairing_code_expires_at > ?", Time.current).sole
    device.update!(status: :paired, room: room, paired_at: Time.current, pairing_code: nil, pairing_code_expires_at: nil)
    device
  rescue ActiveRecord::RecordNotFound, ActiveRecord::SoleRecordExceeded
    raise InvalidPairingCode
  end
end
