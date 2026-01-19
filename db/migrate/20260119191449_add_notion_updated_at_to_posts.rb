class AddNotionUpdatedAtToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :notion_updated_at, :datetime
  end
end
