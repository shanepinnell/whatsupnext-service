class Room < ApplicationRecord
  belongs_to :floor
  has_one_attached :background_image

  validates :name, presence: true, uniqueness: { scope: :floor_id }
end
