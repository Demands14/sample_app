class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  delegate :name, to: :user, prefix: :user, allow_nil: true

  validates :user_id, presence: true
  validates :content, presence: true,
            length: {maximum: Settings.micropost.content.max_length}
  validates :image,
            content_type: {in: Settings.micropost.image.path, message: :format},
            size: {less_than: Settings.micropost.image.size.megabytes,
                   message: :size}

  scope :newest, ->{order created_at: :desc}

  def display_image
    image.variant resize_to_limit: Settings.micropost.image.resize
  end
end
