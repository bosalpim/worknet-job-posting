module NotificationSaveResultHelper
  def save_results_bizm_post_pay(results, template_id)
    return if results.nil? || results.empty?

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

  def save_results_app_push(results, template_id)
    return if results.nil? || results.empty?

    success_count = 0
    fail_count = 0
    fail_reasons = []

    results.each do |result|
      status = result.dig(:status)
      target_public_id = result.dig(:target_public_id)
      response = result.dig(:response)

      if status == "success"
        success_count += 1
      else
        fail_count += 1
        fail_reasons.push("target_public_id : #{target_public_id} #{response}")
      end
    end

    current_date = DateTime.now
    NotificationResult.create!(
      send_type: template_id,
      send_id: "#{current_date.year}/#{current_date.month}/#{current_date.day}/#{template_id}",
      template_id: template_id,
      success_count: success_count,
      tms_success_count: 0,
      fail_count: fail_count,
      fail_reasons: fail_reasons,
      used_medium: 'app_push'
    )
  end
end