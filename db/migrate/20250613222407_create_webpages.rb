class CreateWebpages < ActiveRecord::Migration[8.0]
  def change
    create_table :webpages do |t|
      t.string :url
      t.string :page_title
      t.integer :total_word_count
      t.text :frequent_words
      t.text :table_of_contents

      t.timestamps
    end
  end
end
