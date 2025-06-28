class Webpage < ApplicationRecord
  validates :url, presence: true
end
