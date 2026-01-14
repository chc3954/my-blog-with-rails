class BlogController < ApplicationController
  def index
    service = NotionService.new
    @tags = service.all_tags
    @posts = service.fetch_posts(tag: params[:tag])
  end

  def show
  end
end
