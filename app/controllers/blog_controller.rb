class BlogController < ApplicationController
  def index
    # Renders the skeleton loader view
  end

  def feed
    @tags = Post.published.flat_map(&:tags).tally.sort_by { |_tag, count| -count }.to_h

    if params[:tag]
      # Query by JSON/Array tag field. SQLite/Postgres JSON syntax might differ.
      # For simplicity with array serialization:
      @posts = Post.published.select { |p| p.tags.include?(params[:tag]) }
      # Note: The above Select is in-memory if not using specific JSON operators.
      # Better for production: Post.published.where("tags LIKE ?", "%#{params[:tag]}%") OR native JSON query.
      # Since we are using generic DB, let's keep it simple or check DB adapter.
      # User is using SQLite ("gem 'sqlite3'").
      # SQLite JSON support exists but active record syntax is tricky.
      # Let's simple filter using `where("json_extract(tags, '$') LIKE ?", ...)` or just in-memory if small.
      # Given it's a blog, in-memory filter of <1000 posts is fine.
    else
      @posts = Post.published
    end
    render layout: false
  end

  def show
    @post = Post.find_by(slug: params[:slug])

    if @post.nil?
      render file: "public/404.html", status: :not_found, layout: false
    end
  end
end
