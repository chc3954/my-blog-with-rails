class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :notion_id
      t.string :title
      t.string :slug
      t.text :summary
      t.text :content
      t.date :published_date
      t.json :tags
      t.string :cover_image
      t.string :status

      t.timestamps
    end
    add_index :posts, :notion_id
    add_index :posts, :slug
  end
end
