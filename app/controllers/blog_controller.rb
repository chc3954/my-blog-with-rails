class BlogController < ApplicationController
  def index
    # Renders the skeleton loader view
  end

  def feed
    @total_posts_count = Post.published.count
    @tags = Post.tag_counts

    if params[:tag]
      @posts = Post.published.with_tag(params[:tag])
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
