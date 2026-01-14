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
  end
end
