class Room < ApplicationRecord
  belongs_to :floor
  has_one_attached :background_image
  has_one :calendar_source, dependent: :restrict_with_error
  has_many :devices, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :floor_id }
end
