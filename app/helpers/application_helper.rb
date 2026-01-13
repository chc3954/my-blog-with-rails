module ApplicationHelper
  def page_title
    base_title = "HC Blog"

    if content_for?(:title)
      "#{content_for(:title)} | #{base_title}"
    else
      base_title
    end
  end
end
