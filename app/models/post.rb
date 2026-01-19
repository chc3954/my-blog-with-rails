class Post < ApplicationRecord
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :notion_id, presence: true, uniqueness: true

  has_one_attached :cover
  has_many_attached :content_images

  scope :published, -> { where(status: "Published").order(published_date: :desc) }

  # SQLite specific JSON query
  scope :with_tag, ->(tag) {
    where("exists (select 1 from json_each(posts.tags) where value = ?)", tag)
  }

  def self.tag_counts
    Rails.cache.fetch("post_tag_counts", expires_in: 1.hour) do
      # Calculate tag counts from published posts
      # Flatten all tags and count them
      tags = published.pluck(:tags).flatten
      tags.tally.sort_by { |_tag, count| -count }.to_h
    end
  end

  def cover_url
    if cover.attached?
      Rails.application.routes.url_helpers.rails_blob_url(cover, only_path: true)
    else
      cover_image
    end
  end
end
