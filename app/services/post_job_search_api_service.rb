class PostJobSearchApiService
  def initialize
    @google_service = Google::Apis::IndexingV3::IndexingService.new
    authorization = Google::Auth::ServiceAccountCredentials.make_creds(scope: 'https://www.googleapis.com/auth/indexing')
    @google_service.authorization = authorization
    @url_object = Google::Apis::IndexingV3::UrlNotification.new
    @url_object.type = "URL_UPDATED"
  end

  def call(url)
    post_google(url)
    post_naver(url)
  end

  def post_google(url)
    url_object.url = url
    google_service.publish_url_notification(url_object)
  end

  def post_naver(url)
    response = HTTParty.post(
      "https://apis.naver.com/searchadvisor/crawl-request/submit.json",
      body: JSON.dump(
        {
          "urls": [
            {
              "url": url,
              "type": "update"
            }
          ]
        }
      ),
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer " + ENV['NAVER_SEARCH_API_KEY']
      }
    )

    if response.errorCode
      puts response.errorCode
    end
  end

  private

  attr_reader :url_object, :google_service
end