class NotionService
  def initialize
    @client = Notion::Client.new(token: ENV["NOTION_TOKEN"])
    @database_id = ENV["NOTION_DATABASE_ID"]
  end

  def fetch_posts(tag: nil)
    filter = {
      and: [
        {
          property: "Status",
          select: {
            equals: "Published"
          }
        }
      ]
    }

    if tag
      filter[:and] << {
        property: "Tags",
        multi_select: {
          contains: tag
        }
      }
    end

    sort_by_date = [
      {
        property: "Date",
        direction: "descending"
      }
    ]

    response = @client.database_query(
      database_id: @database_id,
      filter: filter,
      sorts: sort_by_date
    )

    response.results.map do |page|
      parse_page(page)
    end
  end

  def fetch_post(slug)
    filter = {
      and: [
        {
          property: "Status",
          select: {
            equals: "Published"
          }
        },
        {
          property: "Slug",
          rich_text: {
            equals: slug
          }
        }
      ]
    }

    response = @client.database_query(
      database_id: @database_id,
      filter: filter
    )

    page = response.results.first
    return nil unless page

    post_data = parse_page(page)

    # Fetch content
    blocks = @client.block_children(block_id: page.id).results
    parser = BlockParser.new(blocks)
    parsed_result = parser.call

    post_data.merge(
      content: parsed_result[:html],
      toc: parsed_result[:toc]
    )
  end

  def all_tags
    # Fetch all published posts to extract unique tags and their counts
    # Optimization: This could be cached or fetched separately if volume grows
    filter = {
      property: "Status",
      select: {
        equals: "Published"
      }
    }

    response = @client.database_query(
      database_id: @database_id,
      filter: filter
    )

    tags = Hash.new(0)
    response.results.each do |page|
      page.properties["Tags"].multi_select.each do |tag|
        tags[tag.name] += 1
      end
    end
    # Sort by count descending
    tags.sort_by { |_, count| -count }.to_h
  end

  private

  def parse_page(page)
    props = page.properties

    # Safely extract properties handling potential missing values
    title = props["Title"]&.title&.first&.plain_text || "Untitled"
    date = props["Date"]&.date&.start
    slug = props["Slug"]&.rich_text&.first&.plain_text
    summary = props["Summary"]&.rich_text&.first&.plain_text
    tags = props["Tags"]&.multi_select&.map(&:name) || []

    {
      id: page.id,
      title: title,
      date: date,
      slug: slug,
      summary: summary,
      tags: tags,
      cover: page.cover&.external&.url || page.cover&.file&.url
    }
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
