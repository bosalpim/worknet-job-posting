class Fcm::FcmService
  include HTTParty
  base_uri 'https://fcm.googleapis.com'

  def initialize
    authorize
  end

  def send_message(token, message)
    response = self.class.post('/v1/projects/carepartner-app-v1/messages:send',
                               headers: { 'Authorization' => "Bearer #{@auth_token}", 'Content-Type' => 'application/json' },
                               body: message_body(token, message).to_json)

    p response.body
    if response.code == 401 # Unauthorized, possibly due to expired token
      authorize # Re-authorize and get a new token
      response = self.class.post('/v1/projects/carepartner-app-v1/messages:send', # Retry the request with the new token
                                 headers: { 'Authorization' => "Bearer #{@auth_token}", 'Content-Type' => 'application/json' },
                                 body: message_body(token, message).to_json)
    end
    response
  end

  private

  def authorize
    file_path = File.join(Jets.root, 'config', ENV['GOOGLE_APPLICATION_CREDENTIALS'])
    file = File.open(file_path)
    scope = 'https://www.googleapis.com/auth/firebase.messaging'
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: file,
      scope: scope
    )
    @auth_token = authorizer.fetch_access_token!['access_token']
    @token_issued_time = Time.now
  end

  def token_expired?
    Time.now - @token_issued_time > 3300 # Token is considered expired if over 55 minutes have passed
  end

  def message_body(token, message)
    {
      message: {
        token: token,
        notification: {
          title: message[:title],
          body: message[:body]
        }
      }
    }
  end
end
