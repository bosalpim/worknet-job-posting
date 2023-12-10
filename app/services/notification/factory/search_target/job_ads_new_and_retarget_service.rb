class Notification::Factory::SearchTarget::JobAdsNewAndRetargetService
  DISTANCE_LIST = {
    by_walk15: 900,
    by_walk30: 1800,
    by_km_3: 3000,
    by_km_5: 5000,
  }

  def self.call(job_posting, times)
    new(job_posting, times).call
  end

  def initialize(job_posting, times)
    @job_posting = job_posting

    # 2차 / 3차 분기
    @times = times
    @previous_message_template_name = times == 2 ? MessageTemplateName::JOB_ADS_MESSAGE_FIRST : MessageTemplateName::JOB_ADS_MESSAGE_SECOND
  end
  def call
    users = []
    if Jets.env != 'production'
      return [User.last]
    end

    User.preferred_distances.each do |key, value|
      prefer_work_type =
        @job_posting.work_type == 'hospital' ? 'etc' : @job_posting.work_type

      if @job_posting.lat.present? && @job_posting.lng.present?
        target_users = @times == 2 ? User.within_last_7_days.receive_job_notifications : User.receive_job_notifications
        users += target_users
                   .select(
                     "users.*, earth_distance(ll_to_earth(lat, lng), ll_to_earth(#{@job_posting.lat}, #{@job_posting.lng})) AS distance",
                     )
                   .within_radius(
                     DISTANCE_LIST[key.to_sym],
                     @job_posting.lat,
                     @job_posting.lng
                   )
                   .where(preferred_distance: key)
                   .where(
                     'preferred_work_types::jsonb ? :type',
                     type: prefer_work_type,
                     )
                   .where('id not in (?)', users.empty? ? [0] : users.map(&:id))
                   .where(
                     'has_certification = true OR expected_acquisition in (?)',
                     %w[2022/05 2022/08 2022/11 2023/02],
                     )
      end
    end

    # 1차 발송자들 전부 제거
    not_confirmed_id = DispatchedNotification.where(notification_relate_instance_id: @job_posting.id, notification_relate_instance_types_id: 1, message_template_name: @previous_message_template_name)
                                               .where(confirmed: nil)
                                               .pluck(:receiver_id)
    not_confirmed_user = User.where(id: not_confirmed_id)
    users = users - not_confirmed_user

    # retarget 대상 유저 겹치지 않게 추가
    users | retarget_user
  end

  private

  def retarget_user
  # 확인한 사람
  confirmed_receiver_id = DispatchedNotification.where(notification_relate_instance_id: @job_posting.id, notification_relate_instance_types_id: 1, message_template_name: @previous_message_template_name)
                        .where.not(confirmed: nil)
                        .pluck(:receiver_id)
  confirmed_user = User.where(id: confirmed_receiver_id)
  # OR 관심일자리 좋아요
  saved_user_id = @job_posting.user_saved_job_postings.pluck(:user_id)
  saved_user = User.where(id: saved_user_id)

  users = confirmed_user | saved_user

  # AND 전화 기록이 없거나 부재중
  target_user = []
  users.each do |user|
    # 공고에 관련된 안심번호 리스트를 추출해서 관련한 전화가 없는지 추출
    saved_job_vn = UserSavedJobPosting.find_by(job_posting_id: @job_posting.id, user_id: user.id).vn rescue nil
    contact_message_vn = ContactMessage.find_by(job_posting_id: @job_posting.id, user_id: user.id).virtual_number.vn rescue nil
    proposal_vn = Proposal.find_by(job_posting_id: @job_posting.id, user_id: user.id).user_vn rescue nil

    vn_list = [@job_posting.vn, saved_job_vn, contact_message_vn, proposal_vn]
    call_records = CallRecord.where(virtual_number: vn_list)
    from_records_indur = call_records.where(from_number: user.phone_number).pluck(:indur) rescue nil
    to_records = call_records.where(to_number: user.phone_number).pluck(:indur) rescue nil

    if from_records_indur.empty? && to_records.empty?
      target_user.push(user)
      next
    end
  end

  target_user
  end
end