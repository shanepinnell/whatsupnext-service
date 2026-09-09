class Building < ApplicationRecord
  belongs_to :site
  has_many :floors, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :site_id }
  validates :timezone, presence: true
end
