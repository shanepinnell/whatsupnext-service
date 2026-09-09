class Floor < ApplicationRecord
  belongs_to :building
  has_many :rooms, dependent: :restrict_with_error

  positioned on: :building

  validates :name, presence: true, uniqueness: { scope: :building_id }
end
