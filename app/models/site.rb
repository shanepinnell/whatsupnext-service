class Site < ApplicationRecord
  belongs_to :organization
  has_many :buildings

  validates :name, presence: true, uniqueness: { scope: :organization_id }
end
