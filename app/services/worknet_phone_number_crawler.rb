class WorknetPhoneNumberCrawler
  def self.get_phone_number(url)
    begin
      response = HTTParty.post(
        ENV["WORKNET_CRAWLER_API"] + '/api/worknet-phone-number',
        body: { url: url },
        timeout: 10
      )
    rescue Net::ReadTimeout, Net::OpenTimeout => e
      # 타임아웃 예외가 발생하면 로그를 기록합니다.
      Jets.logger.error("CRM TARGET : Timeout occurred while fetching phone number: #{e.message}")
      return nil
    rescue => e
      # 다른 예외에 대해서도 로깅을 하고 nil 반환
      Jets.logger.error("CRM TARGET : Error occurred while fetching phone number: #{e.message}")
      return nil
    end

    if response.nil? || response.body.nil?
      return nil
    end

    response_body = JSON.parse(response.body)
    phone_number = response_body.dig('phoneNumber')

    if phone_number.present?
      return nil
    end

    return phone_number
  end
end