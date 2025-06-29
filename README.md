# GreenFlag

### An app to analyse job ads for inclusive, green, and positive features

## Problem
For many underrepresented communities, access to meaningful job opportunities remains limited. Even as more roles and employers emerge, pathways to these positions are often scattered, poorly advertised, or hidden within exclusive networks—making discovery overwhelming and inaccessible.

Traditional job boards focus narrowly on skills and experience, offering little insight into whether companies value diversity, support flexible work, or uphold environmental responsibility. This lack of transparency hinders job seekers from making informed decisions and limits access to inclusive, values-aligned workplaces—while also preventing employers from effectively showcasing their commitment to equity and sustainability.

## Solution: The GreenFlag Idea
GreenFlag is a values-driven job discovery platform that helps job seekers—particularly those from underrepresented communities—identify inclusive, equitable, and environmentally responsible employers. Unlike traditional job boards that prioritize qualifications alone, GreenFlag highlights what truly matters: company culture, support policies, and sustainability commitments embedded in job descriptions.

By analyzing job postings through web scraping and AI-powered content analysis, GreenFlag surfaces key indicators such as flexible work arrangements, mental health benefits, inclusive hiring practices, and green initiatives. The platform's Key Values Search allows users to filter and prioritize opportunities based on personal values—whether that's pay transparency, fertility support, or environmental impact.

GreenFlag not only empowers job seekers to make informed, values-aligned career decisions, but also supports employers in showcasing their commitment to diversity, inclusion, and sustainability. It bridges the gap between intent and access—transforming how job opportunities are found, evaluated, and shared.

## Implementation
Our solution leverages advanced web scraping technology combined with artificial intelligence to provide comprehensive job posting analysis. The application uses Nokogiri for HTML parsing and content extraction, enabling it to analyze any job posting URL and extract meaningful insights. The system employs a sophisticated keyword detection algorithm that searches for 17 different categories of inclusive language, ranging from fertility support and pay transparency to religious inclusion and carbon neutrality initiatives.

The application is built on a modern Rails 8.0.2 stack with Ruby 3.4.2, utilizing Hotwire and Stimulus for dynamic frontend interactions. The backend processes web content through multiple analysis layers: text extraction, word frequency analysis, table of contents generation, and inclusive terms detection. We integrate OpenAI's GPT-4.1-mini API to provide intelligent job summaries that highlight positive aspects, potential red flags, and concise overviews of each position. The system stores all analysed data in a SQLite database, allowing users to access historical analyses and track trends over time.

Our comprehensive CI/CD pipeline utilizes GitHub Actions to automatically run security scans with Brakeman, enforce code quality with RuboCop, execute comprehensive unit and system tests, and perform smoke tests before deployment, while Dependabot manages daily dependency updates to ensure the application remains secure and up-to-date.

## Challenges
- Most of the team had never used Ruby on Rails before, so there was a steep learning curve.
- We encountered issues getting Rails working on Windows, but overcame them through collaboration and pair programming.
- Time constraints meant we had to scale back some of our vision to focus on delivering a robust MVP.

## Accomplishments & Learnings
- Learnt Ruby and Ruby on Rails from scratch
- Integrated OpenAI API calls within Ruby and displayed the content on the frontend
- Used Excalidraw for rapid wireframing
- Applied MoSCoW prioritisation (Must-have, Should-have, Could-have)
- Implemented user authentication, keyword detection in job descriptions, OpenAI job summary feature, and a searchable library of previous analyses

## Next Steps - Our Vision for GreenFlag
- When someone searches for a job, scrape the company's 'Careers' page to supplement information from the job description
- Integrate data from review sites like Glassdoor to verify company claims
- Migrate the database to Neo4j to build a map of companies and job descriptions over time
- Add a community feature to email companies that lack certain inclusive or green keywords

GreenFlag helps you analyse job ad URLs for:
- The page title
- Total word count
- Top 10 most frequent words (excluding stop words)
- Table of contents (from headings)
- Presence of inclusive, green, and positive keywords/tags (with synonyms and related terms)
- OpenAI-powered summary with Positives, Red Flags, and a brief summary

All analysed pages are saved and can be revisited or searched later.

## Features
- **Keyword/Tag Detection:** Detects a wide range of inclusive, green, and positive job ad features using robust, synonym-aware matching.
- **OpenAI Integration:** Summarises job ads and highlights positives and red flags using GPT-4.
- **Keyword Search:** Find job ads by selecting one or more tags/keywords.
- **User-Friendly UI:** Tabs for analysis sections, navigation bar, and British English throughout.
- **Delete Listings:** (Optional) Delete analysed job ads via the Rails console or (if enabled) from the UI.

## Set up & running the application
- Run `bin/setup` to install dependencies, set up the database and ready the application
- Run `bin/dev` to start the server
- Visit http://127.0.0.1:3000 to view the application

## Deleting Records
- To delete all job ad records, run:
  ```sh
  bin/rails console
  Webpage.destroy_all
  ```
- To delete a specific record:
  ```ruby
  Webpage.find(ID).destroy
  ```
- (Optional) If you enable the delete button in the UI, you can delete from the listings page.

## Technical Details
- Ruby 3.4.2, Rails 8.0.2, SQLite (dev/test)
- Nokogiri for HTML parsing
- OpenAI gem for summaries
- Stimulus for copy-to-clipboard
- Minitest for testing (tests depend on Wikipedia Stegosaurus page)

## Contributing
Pull requests and suggestions welcome!
