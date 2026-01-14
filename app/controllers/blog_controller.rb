class BlogController < ApplicationController
  def index
    # Renders the skeleton loader view
  end

  def feed
    service = NotionService.new
    @tags = service.all_tags
    @posts = service.fetch_posts(tag: params[:tag])
    render layout: false
  end

  def show
    service = NotionService.new
    @post = service.fetch_post(params[:slug])

    if @post.nil?
      render file: "public/404.html", status: :not_found, layout: false
    end
  end
end
