require "open-uri"

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

    # Use the local BlockParser
    parser = BlockParser.new(blocks)
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

    # Handle active storage attachment for cover image
    if cover.present? && !post.cover.attached?
      begin
        downloaded_image = URI.open(cover)
        filename = File.basename(URI.parse(cover).path)
        post.cover.attach(io: downloaded_image, filename: filename)
      rescue => e
        Rails.logger.error("Failed to attach cover image for #{slug}: #{e.message}")
      end
    end

    post.save!
  end

  class BlockParser
    def initialize(blocks)
      @blocks = blocks
      @toc = []
      @html = []
    end

    def call
      @blocks.each do |block|
        render_block(block)
      end
      { html: @html.join, toc: @toc }
    end

    private

    def render_block(block)
      case block.type
      when "paragraph"
        text = render_rich_text(block.paragraph.rich_text)
        @html << "<p class='mb-4 text-gray-300 leading-relaxed'>#{text}</p>" unless text.empty?
      when "heading_1"
        text = block.heading_1.rich_text.map(&:plain_text).join
        id = text.parameterize
        @toc << { id: id, text: text, level: 1 }
        @html << "<h1 id='#{id}' class='text-3xl font-bold mt-12 mb-6 text-white'>#{text}</h1>"
      when "heading_2"
        text = block.heading_2.rich_text.map(&:plain_text).join
        id = text.parameterize
        @toc << { id: id, text: text, level: 2 }
        @html << "<h2 id='#{id}' class='text-2xl font-bold mt-10 mb-5 text-white'>#{text}</h2>"
      when "heading_3"
        text = block.heading_3.rich_text.map(&:plain_text).join
        id = text.parameterize
        @toc << { id: id, text: text, level: 3 }
        @html << "<h3 id='#{id}' class='text-xl font-semibold mt-8 mb-4 text-white'>#{text}</h3>"
      when "bulleted_list_item"
        text = render_rich_text(block.bulleted_list_item.rich_text)
        @html << "<ul class='list-disc list-inside mb-2 text-gray-300 ml-4'><li>#{text}</li></ul>"
      when "numbered_list_item"
        text = render_rich_text(block.numbered_list_item.rich_text)
        @html << "<ol class='list-decimal list-inside mb-2 text-gray-300 ml-4'><li>#{text}</li></ol>"
      when "code"
        code = block.code.rich_text.map(&:plain_text).join
        lang = block.code.language
        @html << "<div class='not-prose my-6 rounded-lg overflow-hidden bg-[#1e1e1e] border border-gray-700'>"
        @html << "<div class='flex justify-between items-center px-4 py-2 bg-[#2d2d2d] border-b border-gray-700 text-xs text-gray-400'>"
        @html << "<span class='uppercase'>#{lang}</span>"
        @html << "</div>"
        @html << "<pre class='p-4 overflow-x-auto text-sm text-gray-200'><code>#{CGI.escapeHTML(code)}</code></pre>"
        @html << "</div>"
      when "image"
        url = block.image.type == "external" ? block.image.external.url : block.image.file.url
        caption = block.image.caption.map(&:plain_text).join
        @html << "<figure class='my-8'>"
        @html << "<img src='#{url}' alt='#{caption}' class='rounded-lg w-full'>"
        @html << "<figcaption class='mt-2 text-center text-sm text-gray-500'>#{caption}</figcaption>" unless caption.empty?
        @html << "</figure>"
      when "quote"
         text = render_rich_text(block.quote.rich_text)
         @html << "<blockquote class='border-l-4 border-blue-500 pl-4 py-2 my-6 italic text-gray-300 bg-gray-800/50 rounded-r-lg'>#{text}</blockquote>"
      end
    rescue => e
      # Fallback for unhandled blocks or errors
      Rails.logger.error("Error rendering block #{block.id}: #{e.message}")
    end

    def render_rich_text(rich_text_array)
      rich_text_array.map do |text_obj|
        content = CGI.escapeHTML(text_obj.plain_text)

        # Apply annotations
        content = "<strong>#{content}</strong>" if text_obj.annotations.bold
        content = "<em>#{content}</em>" if text_obj.annotations.italic
        content = "<u>#{content}</u>" if text_obj.annotations.underline
        content = "<code class='bg-gray-800 text-gray-200 px-1.5 py-0.5 rounded text-sm font-mono'>#{content}</code>" if text_obj.annotations.code # Inline code styled for dark mode
        content = "<span class='line-through'>#{content}</span>" if text_obj.annotations.strikethrough

        if text_obj.href
          content = "<a href='#{text_obj.href}' class='text-blue-400 hover:text-blue-300 underline'>#{content}</a>"
        end

        content
      end.join
    end
  end
end
