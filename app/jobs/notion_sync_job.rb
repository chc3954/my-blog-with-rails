class NotionSyncJob < ApplicationJob
  queue_as :default

  def perform
    NotionSyncService.new.sync_posts
  end
end
