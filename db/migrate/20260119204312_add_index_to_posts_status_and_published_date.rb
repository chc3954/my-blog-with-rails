class AddIndexToPostsStatusAndPublishedDate < ActiveRecord::Migration[8.0]
  def change
    add_index :posts, [:status, :published_date]
  end
end
