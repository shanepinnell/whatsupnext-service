class CalendarSource < ApplicationRecord
  belongs_to :room

  enum :provider, { google: 0, microsoft: 1, ics: 2 }

  serialize :config, coder: JSON
  encrypts :config

  validates :provider, presence: true
  validates :config, presence: true
  validates :room, uniqueness: true

  before_save :bump_credential_version, if: -> { persisted? && config_changed? }

  private

  def bump_credential_version
    self.credential_version += 1
  end
end
