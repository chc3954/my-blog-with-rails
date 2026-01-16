class Post < ApplicationRecord
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :notion_id, presence: true, uniqueness: true

  has_one_attached :cover
  has_many_attached :content_images

  scope :published, -> { where(status: "Published").order(published_date: :desc) }

  def cover_url
    if cover.attached?
      Rails.application.routes.url_helpers.rails_blob_url(cover, only_path: true)
    else
      cover_image
    end
  end
end
