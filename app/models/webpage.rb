class Webpage < ApplicationRecord
  validates :url, presence: true

  serialize :inclusive_terms_found, coder: YAML
  serialize :exclusionary_phrases_found, coder: YAML
  serialize :green_keywords_found, coder: YAML
end
