class SendNewsErrorSlackMessageService
  def self.call
    new.call
  end

  def call
    message = {
      blocks: [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: "일자리신문 발송 오류"
          }
        },
        {
          type: 'section',
          text: {
            type: 'plain_text',
            text: '일자리 신문 발송 도중 오류를 감지했습니다'
          }
        },
        {
          type: 'context',
          elements: [
            {
              type: 'mrkdwn',
              text: "from cloud watch"
            },
          ]
        },
      ],
    }

    SlackWebhookService.call(:newspaper, message)
  end
end