# Web Crawler

### An app to analyze webpages

Upon entering a URL, the app will utilise web parsing and display:
- The page title
- Total word count
- Top 10 most frequent words with their count
- The table of contents

Additionally the data persists and a record of previously entered pages is shown on the homescreen, allowing users to view the analysed information at their leisure.

## Set up & running the application
- Run `bin/setup` to install dependencies, set up the database and ready the application
- Run `bin/dev` to start the server
- Visit http://127.0.0.1:3000 to view the application

## Technical Details
- Project is made using Ruby 3.4.2 and Rails 8.0.2
- Data is analysed using Nokogiri as it is ready for use with rails
- The front end is basic CSS as the focus of the project is a web crawler rather than fully finished project
- The tests are written using minitest and are dependent on the wikipedia page about stegosaurus. Should that page change, some of the tests may fail
- Stimulus is used to create a "copy-to-clipboard" buttton and the code is in `app/javascript/controllers/clipboard_controller.js`
