Webpage.destroy_all

# Creating initial data to seed database for testing purposes

Webpage.create(url: "https://en.wikipedia.org/wiki/Ruby_(programming_language)",
              page_title: "Ruby (programming language) - Wikipedia",
              total_word_count: "3542",
              frequent_words: "<table>
                                <thead>
                                  <tr>
                                    <th>Word</th>
                                    <th>Count</th>
                                  </tr>
                                </thead>
                                <tbody>
                                  <tr><td>Ruby</td><td>120</td></tr>
                                  <tr><td>language</td><td>85</td></tr>
                                  <tr><td>programming</td><td>80</td></tr>
                                  <tr><td>object</td><td>60</td></tr>
                                  <tr><td>code</td><td>55</td></tr>
                                  <tr><td>method</td><td>50</td></tr>
                                  <tr><td>class</td><td>45</td></tr>
                                  <tr><td>data</td><td>40</td></tr>
                                  <tr><td>syntax</td><td>35</td></tr>
                                  <tr><td>interpreter</td><td>30</td></tr>
                                </tbody>
                              </table>",
              table_of_contents: "<ol>
                                    <li>History
                                      <ol>
                                        <li>Early development</li>
                                        <li>Public release</li>
                                        <li>Ruby 1.8 and 1.9</li>
                                        <li>Ruby 2.0 and later</li>
                                        <li>Ruby 3</li>
                                      </ol>
                                    </li>
                                    <li>Features</li>
                                    <li>Philosophy</li>
                                    <li>Syntax and semantics
                                      <ol>
                                        <li>Names</li>
                                        <li>Variables</li>
                                        <li>Control structures</li>
                                        <li>Classes and methods</li>
                                        <li>Blocks and iterators</li>
                                        <li>Mixins</li>
                                        <li>Metaprogramming</li>
                                      </ol>
                                    </li>
                                    <li>Implementation</li>
                                    <li>Standard library</li>
                                    <li>Package management</li>
                                    <li>Development tools</li>
                                    <li>Adoption
                                      <ol>
                                        <li>Industry use</li>
                                        <li>Education</li>
                                        <li>Community</li>
                                      </ol>
                                    </li>
                                    <li>See also</li>
                                    <li>References</li>
                                    <li>External links</li>
                                  </ol>")
