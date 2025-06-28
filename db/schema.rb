# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_28_153034) do
  create_table "webpages", force: :cascade do |t|
    t.string "url"
    t.string "page_title"
    t.integer "total_word_count"
    t.text "frequent_words"
    t.text "table_of_contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "inclusive_terms_found"
    t.text "exclusionary_phrases_found"
    t.text "green_keywords_found"
    t.text "full_text"
    t.text "openai_summary"
  end
end
