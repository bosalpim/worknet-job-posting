class WorknetPhoneNumberCrawler

  def self.login
    begin
      response = HTTParty.post(
        ENV["WORKNET_CRAWLER_API"] + '/api/worknet-login',
        timeout: 30
      ).parsed_response

      return response
    rescue Net::ReadTimeout, Net::OpenTimeout => e
      Jets.logger.error("Crawler Worknet Login : Timeout occurred while fetching phone number: #{e.message}")
      return nil
    rescue => e
      Jets.logger.error("Crawler Worknet Login : Error occurred while fetching phone number: #{e.message}")
      return nil
    end
  end
  def self.get_phone_number(url)
    begin
      response = HTTParty.post(
        ENV["WORKNET_CRAWLER_API"] + '/api/worknet-phone-number',
        body: { url: url },
        timeout: 30
      ).parsed_response

      if response.nil?
        return nil
      end

      phone_number = response.dig('phoneNumber')
      unless phone_number.present?
        return nil
      end

      return phone_number
    rescue Net::ReadTimeout, Net::OpenTimeout => e
      # 타임아웃 예외가 발생하면 로그를 기록합니다.
      Jets.logger.error("CRM TARGET : Timeout occurred while fetching phone number: #{e.message}")
      return nil
    rescue => e
      # 다른 예외에 대해서도 로깅을 하고 nil 반환
      Jets.logger.error("CRM TARGET : Error occurred while fetching phone number: #{e.message}")
      return nil
    end
  end
end