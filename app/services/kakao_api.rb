class KakaoApi
  include ExtendedHttparty

  ADDRESS_SEARCH_PATH  = "/local/search/address.json".freeze

  def initialize
    @base_url = "https://dapi.kakao.com/v2"
  end

  def search_address(address)
    response = send_request(
      ADDRESS_SEARCH_PATH,
      body: {
        query: address&.split(",")&.first
      }
    )
    if (address_document = response["documents"][0])
      {
        lat: address_document.dig("y")&.slice(..10),
        lng: address_document.dig("x")&.slice(..10)
      }
    else
      {
        lat: nil,
        lng: nil
      }
    end
  end

  private

  attr_reader :base_url

  def send_request(path, body: {}, headers: {})
    HTTParty.get(base_url + path, {
      headers: {
        **headers,
        Authorization: "KakaoAK #{ENV['KAKAO_REST_API_KEY']}"
      },
      body: URI.encode_www_form(body),
      verify: true
    })
  end
end