class AddKeywordTagsFoundToWebpages < ActiveRecord::Migration[8.0]
  def change
    add_column :webpages, :keyword_tags_found, :text
  end
end
