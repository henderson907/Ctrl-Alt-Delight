class AddFullTextAndOpenaiSummaryToWebpages < ActiveRecord::Migration[8.0]
  def change
    add_column :webpages, :full_text, :text
    add_column :webpages, :openai_summary, :text
  end
end
