class Site < ApplicationRecord
  belongs_to :organization
  has_many :buildings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :organization_id }
end
