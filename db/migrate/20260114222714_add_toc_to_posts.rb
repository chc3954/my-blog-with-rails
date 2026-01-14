class AddTocToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :toc, :json
  end
end
