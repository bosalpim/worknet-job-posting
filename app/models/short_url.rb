class ShortUrl < ApplicationRecord
  validates_presence_of :original_url

  def self.build(url)
    short_url = ShortUrl.find_by(original_url: url)

    if short_url.blank?
      slug = loop do
        random_slub = SecureRandom.base36(10)
        break random_slub unless ShortUrl.exists?(slug: random_slub)
      end

      short_url = ShortUrl.create(
        original_url: url,
        url: "https://carepartner.kr/s/#{slug}",
        slug: slug
      )
    end

    return short_url
  end
end
