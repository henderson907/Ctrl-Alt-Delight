require "test_helper"

class WebpageTest < ActiveSupport::TestCase
  test "should not save webpage without a url" do
    webpage = Webpage.new
    assert_not webpage.save, "Saved webpage without a url"
  end
end
