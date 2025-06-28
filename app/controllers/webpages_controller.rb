require "nokogiri"
require "open-uri"

class WebpagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show, :create ]
  before_action :webpage_params, only: [ :create ]

  def index
    @webpages = Webpage.all
    @webpage = Webpage.new
  end

  def show
    @webpage = Webpage.find(params[:id])
  end

  def create
    @webpage = Webpage.new(webpage_params)
    doc = parse_url(@webpage.url)
    # Ensures we have a valid webpage html, otherwise it sends an error message
    if doc != ""
      @webpage.page_title = page_title(doc)
      @webpage.table_of_contents = table_of_contents(doc)
      word_list = word_analysis(doc)
      @webpage.total_word_count = calculate_total_words(word_list)
      @webpage.frequent_words = format_frequent_words(word_list)
      if @webpage.save
        redirect_to webpage_path(@webpage)
      else
        flash[:alert] = "Hmm, looks like something went wrong"
        redirect_to root_path
      end
    else
      flash[:alert] = "You must enter a valid URL"
      redirect_to root_path
    end
  end

  private

  # Uses nokogiri to parse the html from the given url
  def parse_url(url)
    # Checks there is a url given
    if url == ""
      return ""
    end
    begin
      html = URI.open(url)
      Nokogiri::HTML.parse(html)
    rescue Socket::ResolutionError, OpenURI::HTTPError
      ""
    end
  end

  # Finds the page title using the css selector "title"
  def page_title(doc)
    doc.search("title").text
  end

  # Generates the HTML for the table of contents
  def table_of_contents(doc)
    headers = ""
    contents = doc.search("h2, h3")
    contents.each_with_index do |header, i|
      if i == 0
        # We start by opening an ol and li tag
        headers += "<ol><li>#{header.text}"
      elsif header.name == "h2" && contents[i-1].name == "h2"
        # this and previous header are both h2, and so we close the previous li tag and open the next
        headers += "</li><li>#{header.text}"
      elsif header.name == "h3" && contents[i-1].name == "h2"
        # This is a subheading of the previous heading so we open an ol and an li tag
        headers += "<ol><li>#{header.text}"
      elsif header.name == "h2" && contents[i-1].name == "h3"
        # This is a heading whereas the previous was a subheading so we close the li and the ol tags and then open a new li tag
        headers += "</li></ol><li>#{header.text}"
      elsif header.name == "h3" && contents[i-1].name == "h3"
        # Both this and the previous are subheadings so we close the li and open the next li
        headers += "</li><li>#{header.text}"
      end
    end
    # We close the li and ol tag
    headers += "</li></ol>"
  end

  # Extracts the words from the nokogiri document
  def word_analysis(doc)
    # removing elements that will not show up on screen
    doc.css("script").remove
    doc.css("style").remove
    doc.css("meta").remove
    text = doc.text
    text.scan(/[a-zA-Z]+/)
  end

  # Calculates the number of words on page
  def calculate_total_words(word_list)
    word_list.length
  end

  # Sends for top_words method and then formats the results as an ordered list
  def format_frequent_words(word_list)
    top_ten_words = top_words(word_list)
    list_els = top_ten_words.map do |key, value|
      "<tr><td>#{key}</td><td>#{value}</td></tr>"
    end
    "<table><thead><tr><th>Word</th><th>Count</th></tr></thead><tbody>#{list_els.join("")}</tbody></table>"
  end

  # Calculates frequency of each word and returns top 10
  def top_words(word_list)
    words = Hash[
      word_list.group_by(&:downcase).map { |word, instances|
        [ word, instances.length ]
      }.sort_by(&:last).reverse
    ]
    words.first(10).to_h
  end

  def webpage_params
    params.require(:webpage).permit(:url)
  end
end
