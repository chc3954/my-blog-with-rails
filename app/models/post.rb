class Post < ApplicationRecord
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :notion_id, presence: true, uniqueness: true

  scope :published, -> { where(status: "Published").order(published_date: :desc) }
end
