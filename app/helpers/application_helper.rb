module ApplicationHelper
  MAX_ITEM_LIST_TEXT_LENGTH = 19.freeze
  def carepartner_base_url
    if Jets.env.production?
       "https://carepartner.kr"
    elsif Jets.env.staging?
       "https://dev-carepartner.kr"
    else
       "http://localhost:3000"
    end
  end

  def build_shorten_url(origin_url)
    ShortUrl.build(origin_url).url
  end
  def convert_safe_text(text, empty_string = "정보없음")
    text.presence&.truncate(MAX_ITEM_LIST_TEXT_LENGTH) || empty_string
  end

  def send_message(data, template_id)
    results = []

    data.each_slice(10) do |batch|
      threads = []

      batch.each do |element|
        threads << Thread.new do
          begin
            rsp = BizmsgService.call(
              template_id: template_id,
              phone: element[:phone_number],
              message_type: "AI",
              template_params: element[:tem_params]
            )

            results.push({ status: 'success', response: rsp, target_public_id: element[:target_public_id] })
          rescue Net::ReadTimeout
            msg = "#{element[:target_public_id]} NET::TIMEOUT"
            Jets.logger.info msg
            results.push({ status: 'fail', response: "NET::TIMEOUT", target_public_id: element[:target_public_id] })
          rescue HTTParty::Error => e
            msg = "#{element[:target_public_id]} HTTParty::Error #{e.message}"
            Jets.logger.info msg
            results.push({ status: 'fail', response: "#{e.message}", target_public_id: element[:target_public_id] })
          end
        end
      end

      threads.each(&:join)
    end

    results
  end

  def process_results(results, template_id)
    success_count = 0
    tms_success_count = 0
    fail_count = 0
    fail_reasons = []

    results.each do |result|
      status = result.dig(:status)
      target_public_id = result.dig(:target_public_id)
      response = result.dig(:response)

      if status == 'fail'
        fail_count += 1
        fail_reasons.push("target_public_id : #{target_public_id} #{response}")
      else
        if response.dig("result") == "Y"
          if response.dig("code") == "K000"
            success_count += 1
          else
            fail_reasons.push("target_public_id : #{target_public_id}, error: #{response.dig("error")}")
            tms_success_count += 1
          end
        else
          fail_reasons.push("target_public_id : #{target_public_id}, error: #{response.dig("error")}")
          fail_count += 1
        end
      end
    end

    current_date = DateTime.now
    NotificationResult.create!(
      send_type: template_id,
      send_id: "#{current_date.year}/#{current_date.month}/#{current_date.day}#{template_id}",
      template_id: template_id,
      success_count: success_count,
      tms_success_count: tms_success_count,
      fail_count: fail_count,
      fail_reasons: fail_reasons
    )
  end
end
