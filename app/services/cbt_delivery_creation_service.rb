class CbtDeliveryCreationService
  def self.call
    new.call
  end

  def initialize
  end

  def call
    create_delivery
  end

  def create_delivery
    token = Main::CBT_DELIVERY_BEARER_TOKEN
    cbt_api_url = Main::CBT_API_URL

    response = HTTParty.post(
      "#{cbt_api_url}/daily-delivery/question-set/next-week",
      headers: {
        "Authorization" => "Bearer #{token}",
        "Content-Type" => "application/json"
      }
    )

    if response.success? && response.parsed_response["success"] == true
      Jets.logger.info "CbtDeliveryCreationJob Success: #{response.body}"
      log success_message
    else
      Jets.logger.error "CbtDeliveryCreationJob Failed: #{response.code} - #{response.body}"
      log fail_message
    end
  end

  def log(message)
    SlackWebhookService.call(:newspaper, message) if message.present?
    Jets.logger.info message if message.present?
  end

  def success_message
    {
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: "문제배달 생성 완료"
          }
        }
      ],
    }
  end

  def fail_message(e = StandardError.new)
    {
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: "문제배달 생성 오류"
          }
        },
        {
          type: 'section',
          text: {
            type: 'plain_text',
            text: '<@U0585GV1HK2>'
          }
        },
        {
          type: 'context',
          elements: [
            {
              type: 'mrkdwn',
              text: "```
#{e.message}
```"
            },
          ]
        },
      ],
    }
  end

end
