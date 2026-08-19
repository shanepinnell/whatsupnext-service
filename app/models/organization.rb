class Organization < ApplicationRecord
  has_many :sites

  has_rich_text :support_information

  validates :name, presence: true
end
