class Building < ApplicationRecord
  belongs_to :site
  has_many :floors

  validates :name, presence: true, uniqueness: { scope: :site_id }
  validates :timezone, presence: true
end
