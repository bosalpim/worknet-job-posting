class PostNaverCrawlingApiService

  def call(url)
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

end

