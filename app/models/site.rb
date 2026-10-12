class Site < ApplicationRecord
  belongs_to :organization
  has_many :buildings, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :organization_id }
  validates :timezone, presence: true, inclusion: { in: TZInfo::Timezone.all_identifiers, allow_blank: true }
end
