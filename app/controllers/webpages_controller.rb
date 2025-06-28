require "nokogiri"
require "open-uri"
require 'openai'
require 'dotenv/load'

class WebpagesController < ApplicationController
  before_action :webpage_params, only: [ :create ]

  INCLUSIVE_TERMS = {
    parental_leave: ["maternity leave", "paternity leave", "parental leave"],
    mental_health: ["mental health", "wellbeing", "counselling"],
    remote_friendly: ["remote-friendly", "hybrid", "flexible working"],
    disability_support: ["reasonable adjustments", "wheelchair accessible", "neurodiverse"],
    lgbtq_inclusive: ["LGBTQ+", "Pride", "inclusive culture"],
  }

  EXCLUSIONARY_PHRASES = ["must-have", "rockstar", "native english", "perfect communication"]

  GREEN_KEYWORDS = ["sustainability", "climate", "net zero", "carbon", "energy", "renewable"]

  STOP_WORDS = %w[the of and a to in is it you that he was for on are as with his they I at be this have from or one had by word but not what all were we when your can said there use an each which she do how their if]

  def index
    @webpages = Webpage.all
    @webpage = Webpage.new
  end

  def show
    @webpage = Webpage.find(params[:id])
    # For display in the show view
    @inclusive_terms_found = @webpage.inclusive_terms_found
    @exclusionary_phrases_found = @webpage.exclusionary_phrases_found
    @green_keywords_found = @webpage.green_keywords_found
  end

  def create
    @webpage = Webpage.new(webpage_params)
    doc = parse_url(@webpage.url)
    if doc != ""
      @webpage.page_title = page_title(doc)
      @webpage.table_of_contents = table_of_contents(doc)
      word_list = word_analysis(doc)
      @webpage.total_word_count = calculate_total_words(word_list)
      @webpage.frequent_words = format_frequent_words(word_list)
      text = doc.text
      @webpage.full_text = text
      @webpage.inclusive_terms_found = keyword_presence(text, INCLUSIVE_TERMS)
      @webpage.exclusionary_phrases_found = phrase_presence(text, EXCLUSIONARY_PHRASES)
      @webpage.green_keywords_found = phrase_presence(text, GREEN_KEYWORDS)
      # Call OpenAI for summary and red flags
      @webpage.openai_summary = get_openai_summary(text)
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

  def table_of_contents(doc)
    headers = ""
    contents = doc.search("h2, h3")
    contents.each_with_index do |header, i|
      if i == 0
        headers += "<ol><li>#{header.text}"
      elsif header.name == "h2" && contents[i-1].name == "h2"
        headers += "</li><li>#{header.text}"
      elsif header.name == "h3" && contents[i-1].name == "h2"
        headers += "<ol><li>#{header.text}"
      elsif header.name == "h2" && contents[i-1].name == "h3"
        headers += "</li></ol><li>#{header.text}"
      elsif header.name == "h3" && contents[i-1].name == "h3"
        headers += "</li><li>#{header.text}"
      end
    end
    headers += "</li></ol>"
  end

  def word_analysis(doc)
    doc.css("script").remove
    doc.css("style").remove
    doc.css("meta").remove
    text = doc.text
    words = text.scan(/[a-zA-Z]+/)
    words.reject { |word| STOP_WORDS.include?(word.downcase) }
  end

  def calculate_total_words(word_list)
    word_list.length
  end

  def format_frequent_words(word_list)
    top_ten_words = top_words(word_list)
    list_els = top_ten_words.map do |key, value|
      "<tr><td>#{key}</td><td>#{value}</td></tr>"
    end
    "<table><thead><tr><th>Word</th><th>Count</th></tr></thead><tbody>#{list_els.join("")}</tbody></table>"
  end

  def top_words(word_list)
    words = Hash[
      word_list.group_by(&:downcase).map { |word, instances|
        [ word, instances.length ]
      }.sort_by(&:last).reverse
    ]
    words.first(10).to_h
  end

  def keyword_presence(text, keyword_hash)
    results = {}
    keyword_hash.each do |category, phrases|
      found = phrases.select do |phrase|
        text.downcase.include?(phrase.downcase)
      end
      results[category] = found unless found.empty?
    end
    results
  end

  def phrase_presence(text, phrases)
    phrases.select { |phrase| text.downcase.include?(phrase.downcase) }
  end

  def get_openai_summary(text)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    prompt = <<~PROMPT
      Here is a job description:
      #{text}

      Please provide a brief summary of whether this is a good job to apply for, and mention any red flags or concerns you notice.
    PROMPT
    response = client.chat(
      parameters: {
        model: "gpt-4.1-mini-2025-04-14",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.7
      }
    )
    response.dig("choices", 0, "message", "content")
  rescue => e
    Rails.logger.error "OpenAI API error: #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    Rails.logger.error "Prompt: #{prompt.inspect}"
    "OpenAI summary unavailable: #{e.class}: #{e.message}"
  end

  def webpage_params
    params.require(:webpage).permit(:url)
  end
end
