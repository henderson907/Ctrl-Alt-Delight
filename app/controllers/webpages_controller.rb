require "nokogiri"
require "open-uri"
require "openai"
require "dotenv/load"

class WebpagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show, :new, :create ]
  before_action :webpage_params, only: [ :create ]

  # Updated keyword tags as requested
  KEYWORD_TAGS = {
    fertility_support: [ "fertility support", "menopause care" ],
    pay_transparency: [ "pay transparency", "salary transparency" ],
    flexible_work: [ "flexible work hours", "remote-first", "flexible schedule", "hybrid working" ],
    name_blind_recruitment: [ "name-blind recruitment" ],
    religious_inclusion: [ "prayer space", "flexible religious leave", "eid leave", "religious holidays" ],
    lgbtq_inclusive: [ "lgbtqia+", "pride", "queer inclusive" ],
    alt_education: [ "non-traditional educational background", "no degree required", "bootcamp graduate" ],
    ethnic_networks: [ "black employee network", "asian employee network", "diversity network" ],
    accessibility: [ "step-free access", "wheelchair accessible", "accessible office" ],
    inclusive_env: [ "inclusive work environment", "inclusive culture" ],
    green_career: [ "green career", "climate job", "sustainability role" ],
    mental_health: [ "mental health", "mental health days", "counselling", "wellbeing" ],
    social_sustainability: [ "social sustainability" ],
    wellness_programs: [ "wellness programs", "health & wellness", "gym membership" ],
    cycling_scheme: [ "bike-to-work scheme", "cycle to work" ],
    carbon_neutral: [ "carbon neutrality", "carbon neutral", "net zero" ]
  }

  STOP_WORDS = %w[the of and a to in is it you that he was for on are as with his they I at be this have from or one had by word but not what all were we when your can said there use an each which she do how their if]

  def index
    @webpages = Webpage.all
    @webpage = Webpage.new
  end

  def show
    @webpage = Webpage.find(params[:id])
    begin
      @keyword_tags_found = @webpage.keyword_tags_found
    rescue Psych::SyntaxError
      @keyword_tags_found = {}
    end
  end

  def new
    @webpage = Webpage.new
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
      @webpage.keyword_tags_found = keyword_presence(text, KEYWORD_TAGS)
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

  def keyword_search
    @all_keywords = KEYWORD_TAGS.keys.map(&:to_s)
    @selected_keywords = params[:keywords] || []
    @jobs = []
  end

  def keyword_search_results
    @all_keywords = KEYWORD_TAGS.keys.map(&:to_s)
    @selected_keywords = params[:keywords] || []
    @jobs = filter_jobs_by_keywords(@selected_keywords)
    render :keyword_search
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

  def get_openai_summary(text)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    prompt = <<~PROMPT
      Here is a job description:
      #{text}

      Please return only the following three sections, each clearly labeled:
      1. Positives: List the positive aspects of this job.
      2. Red Flags: List any concerns or red flags.
      3. Summary: Provide a brief summary of the job in 1-2 sentences.
    PROMPT
    response = client.chat(
      parameters: {
        model: "gpt-4.1-mini-2025-04-14",
        messages: [ { role: "user", content: prompt } ],
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

  def filter_jobs_by_keywords(selected_keywords)
    return [] if selected_keywords.blank?
    Webpage.where.not(keyword_tags_found: nil).select do |webpage|
      found = (webpage.keyword_tags_found || {}).keys.map(&:to_s)
      (found & selected_keywords).any?
    end
  end

  def webpage_params
    params.require(:webpage).permit(:url)
  end
end
