require "test_helper"

class WebpagesControllerTest < ActionDispatch::IntegrationTest
  # When given a blank url, we are redirected to the root page and flash is generated
  test "should generate a flash and redirect to root path when given a blank url" do
    post webpages_path, params: { webpage: { url: "" } }
    assert_equal "You must enter a valid URL", flash[:alert], "does not render a flash"
    assert_redirected_to root_path, "does not redirect to root path"
  end

  # If url is not found, they are redirected to the root page and flash is generated
  test "should redirect to root path when given invalid url" do
    post webpages_path, params: { webpage: { url: "http://srbfjsrnfkjnrwkjfjsnfjbrjhbferjbf.com" } }
    assert_equal "You must enter a valid URL", flash[:alert], "does not render a flash"
    assert_redirected_to root_path, "does not redirect to root path"
  end

  # When given a valid url, the user is redirected to the correspinding show page
  test "should redirect to show page when given a valid url" do
    post webpages_path, params: { webpage: { url: "https://en.m.wikipedia.org/wiki/Stegosaurus" } }
    assert_redirected_to webpage_path(Webpage.last), "does not redirect to root page"
  end

  # The page title is extracted and saved as part of the record
  test "should have page_title as non-blank column in record" do
    post webpages_path, params: { webpage: { url: "https://en.m.wikipedia.org/wiki/Stegosaurus" } }
    @webpage = Webpage.last
    assert_equal "Stegosaurus - Wikipedia", @webpage.page_title, "does not correctly extract page_title"
  end

  # The word count is calculated and saved as an integer
  test "should have total_word_count as non-blank column in record" do
    post webpages_path, params: { webpage: { url: "https://en.m.wikipedia.org/wiki/Stegosaurus" } }
    @webpage = Webpage.last
    assert_equal 12066, @webpage.total_word_count, "does not retrieve total word count correctly"
  end

  # A table of contents is generated
  test "should have table_of_contents as non-blank column in record" do
    post webpages_path, params: { webpage: { url: "https://en.m.wikipedia.org/wiki/Stegosaurus" } }
    @webpage = Webpage.last
    assert_not_empty @webpage.table_of_contents, "does not have a table of contents"
  end

  # The word frequency is calculated and only 10 records are included
  test "should have 10 rows in frequent_words column, plus a header row" do
    post webpages_path, params: { webpage: { url: "https://en.m.wikipedia.org/wiki/Stegosaurus" } }
    @webpage = Webpage.last
    table_rows = @webpage.frequent_words.scan(/<tr>/).count
    assert_equal 11, table_rows, "does not contain exactly 10 words"
  end
end
