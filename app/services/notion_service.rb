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
end
