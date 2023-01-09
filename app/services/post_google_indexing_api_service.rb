class PostGoogleIndexingApiService
  def initialize
    @google_service = Google::Apis::IndexingV3::IndexingService.new
    authorization = Google::Auth::ServiceAccountCredentials.make_creds(scope: 'https://www.googleapis.com/auth/indexing')
    @google_service.authorization = authorization
    @url_object = Google::Apis::IndexingV3::UrlNotification.new
    @url_object.type = "URL_UPDATED"
  end

  def call(url)
    url_object.url = url
    google_service.publish_url_notification(url_object)
  end

  private

  attr_reader :url_object, :google_service
end