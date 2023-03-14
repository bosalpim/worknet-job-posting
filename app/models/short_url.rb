class ShortUrl < ApplicationRecord
  validates_presence_of :original_url

  def self.build(url, base_url = "https://carepartner.kr")
    existing = ShortUrl.find_by(original_url: url)

    if existing.blank?
      slug = loop do
        random_slug = SecureRandom.base36(10)
        break random_slug unless ShortUrl.exists?(slug: random_slug)
      end

      existing = ShortUrl.create(
        original_url: url,
        url:"#{base_url}/s/#{slug}",
        slug: slug
      )
    end

    return existing
  end
end
