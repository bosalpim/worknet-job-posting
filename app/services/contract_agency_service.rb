class ContractAgencyService
  #   4일전, 3일전 내역
  def initialize(days)
    @days = days
  end

  def self.call(days)
    new(days).call
  end

  def call
    job_posting_ids = JobPostingsConnect
                        .where(created_at: 4.days.ago...)
                        .where({ is_connect_success: true })
                        .where.not(job_posting_id: nil)
                        .distinct(:job_posting_id)
                        .pluck(:job_posting_id)

    data_array = JobPosting.where(id: job_posting_ids)
                           .where.not(manager_phone_number: nil)
                           .distinct(:manager_phone_number)
                           .pluck(:business_id, :manager_phone_number)

    send_data = data_array.map do |element|
      { business_id: element[0], manager_phone_number: element[1] }
    end

    # 서비스 콜
    result = batch_send_message(send_data)
    Jets.logger.info result
    result
  end

  def batch_send_message(send_data)
    results = []
    time_out_messages = []
    time_out_total = 0

    send_data.each_slice(10) do |batch|
      threads = []
      batch_results = []
      batch.each do |data|
        threads << Thread.new do
          start_time = Time.now
          begin
            response = KakaoNotificationService.call(
              template_id: KakaoTemplate::CONTRACT_AGENCY_ALARM,
              message_type: 'AT',
              phone: data.dig(:manager_phone_number),
              template_params: { business_id: data.dig(:business_id) }
            )
            batch_results.push({ status: 'success', response: response, message: data })
          rescue Net::ReadTimeout
            end_time = Time.now
            time_out_total += (start_time - end_time)
            time_out_messages.push(message)
          rescue HTTParty::Error => e
            batch_results.push({ status: 'fail', response: "#{e.message}" })
          end
        end
      end

      threads.each(&:join)
      results.concat(batch_results)
    end

    return {
      results: results,
      time_out_messages: time_out_messages,
      time_out_average: time_out_messages.length > 0 ? time_out_total / time_out_messages.length : 0
    }
  end
end