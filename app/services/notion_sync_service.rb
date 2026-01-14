class NotionSyncService
  def initialize
    @client = Notion::Client.new(token: ENV["NOTION_TOKEN"])
    @database_id = ENV["NOTION_DATABASE_ID"]
  end

  def sync_posts
    Rails.logger.info "Starting Notion sync..."

    # 1. Fetch all published pages from Notion
    pages = fetch_all_pages

    # 2. Sync each page
    pages.each do |page|
      sync_page(page)
    end

    Rails.logger.info "Notion sync complete. Synced #{pages.count} posts."
  end

  private

  def fetch_all_pages
    filter = {
      property: "Status",
      select: {
        equals: "Published"
      }
    }

    posts = []

    # Simple pagination handling
    has_more = true
    start_cursor = nil

    while has_more
      query_options = {
        database_id: @database_id,
        filter: filter
      }
      query_options[:start_cursor] = start_cursor if start_cursor

      response = @client.database_query(query_options)

      posts.concat(response.results)
      has_more = response.has_more
      start_cursor = response.next_cursor
    end

    posts
  end

  def sync_page(page)
    props = page.properties
    slug = props["Slug"]&.rich_text&.first&.plain_text

    return unless slug.present? # Skip if no slug

    # Fetch content (blocks)
    blocks = @client.block_children(block_id: page.id).results

    # Use the existing BlockParser from NotionService
    parser = NotionService::BlockParser.new(blocks)
    parsed_result = parser.call

    post = Post.find_or_initialize_by(notion_id: page.id)

    title = props["Title"]&.title&.first&.plain_text || "Untitled"
    summary = props["Summary"]&.rich_text&.first&.plain_text
    date_str = props["Date"]&.date&.start
    tags = props["Tags"]&.multi_select&.map(&:name) || []
    cover = page.cover&.external&.url || page.cover&.file&.url
    status = props["Status"]&.[]("select")&.name

    post.assign_attributes(
      title: title,
      slug: slug,
      summary: summary,
      content: parsed_result[:html],
      toc: parsed_result[:toc],
      published_date: date_str,
      tags: tags, # Active Record JSON serialization handles array automatically
      cover_image: cover,
      status: status
    )

    post.save!
  end
end
