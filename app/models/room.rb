class Room < ApplicationRecord
  belongs_to :floor
  has_one_attached :background_image
  has_one :calendar_source, dependent: :restrict_with_error
  has_many :devices, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :floor_id }
  validates :background_image, content_type: %w[ image/jpeg image/png image/webp ],
    dimension: { width: { min: 1920, max: 3840 }, height: { min: 1080, max: 2160 } },
    aspect_ratio: :is_16_9
end
