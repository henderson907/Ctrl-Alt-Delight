class AddKeywordFieldsToWebpages < ActiveRecord::Migration[8.0]
  def change
    add_column :webpages, :inclusive_terms_found, :text
    add_column :webpages, :exclusionary_phrases_found, :text
    add_column :webpages, :green_keywords_found, :text
  end
end
