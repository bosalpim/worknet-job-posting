class Fcm::FcmService
  include Singleton
  include HTTParty
  base_uri 'https://fcm.googleapis.com'

  def initialize
    authorize
    @candidate_token_list = []
  end

  def get_candidate_push_token_info(tokens)
    @candidate_token_list = UserPushToken.where(token: tokens).pluck(:token, :app_version)
  end

  def send_message(token, message)
    response = self.class.post('/v1/projects/carepartner-app-v1/messages:send',
                               headers: { 'Authorization' => "Bearer #{@auth_token}", 'Content-Type' => 'application/json' },
                               body: message_body(token, message).to_json)

    if response.code == 401 # Unauthorized, possibly due to expired token
      authorize # Re-authorize and get a new token
      response = self.class.post('/v1/projects/carepartner-app-v1/messages:send', # Retry the request with the new token
                                 headers: { 'Authorization' => "Bearer #{@auth_token}", 'Content-Type' => 'application/json' },
                                 body: message_body(token, message).to_json)
    end

    result = { success: response.code == 200 }
    result["errorCode"] = response['error']['details'].first['errorCode'] if response.code != 200
    result
  end

  private

  def authorize
    json = nil
    if Jets.env.development?
      file_path = File.join(Jets.root, 'FIREBASE_ADMIN_JSON.json')
      json = File.open(file_path)
    else
      file_path = File.join(Jets.root, 'config', 'FB_ADMIN_JSON.json')
      json = File.open(file_path)
    end

    scope = 'https://www.googleapis.com/auth/firebase.messaging'
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: json,
      scope: scope
    )

    @auth_token = authorizer.fetch_access_token!['access_token']
    @token_issued_time = Time.now
  end

  def token_expired?
    Time.now - @token_issued_time > 3300 # Token is considered expired if over 55 minutes have passed
  end

  def message_body(token, message)
    candidate = @candidate_token_list.find { |entry| entry[0] == token }
    if candidate && candidate[1] == "2.0.0"
      {
        message: {
          token: token,
          data: {
            title: message[:title],
            body: message[:body],
            deeplink: message[:link]
          },
        }
      }
    else
      {
        message: {
          token: token,
          notification: {
            title: message[:title],
            body: message[:body]
          },
          data: {
            deeplink: message[:link]
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'high_importance_channel',
              title: message[:title],
              body: message[:body],
            }
          }
        }
      }
    end
  end
end
