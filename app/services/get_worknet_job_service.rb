class GetWorknetJobService
  def self.call
    new.call
  end

  def initialize
  end

  def call
    create_job_postings_by_worknet
  end

  private

  # attr_reader :test

  def create_job_postings_by_worknet
    loop.with_index do |_, index|
      puts "================= Page: #{index + 1} ================="
      data = WorknetApiService.call(index + 1, "L", nil, 100, "D-0")&.dig("wantedRoot")
      if data.present?
        message_code = data.dig("messageCd")
        return if message_code == "006" || data.dig("total") == "0"  # 정보가 더 이상 존재하지 않는 경우

        jobs = data.dig("wanted")
        if jobs.length > 0
          create_worknet_job_postings(jobs)
        else
          return
        end
      end
    end
  end

  def create_worknet_job_postings(jobs)
    google_api_service = PostGoogleIndexingApiService.new rescue nil
    if jobs.class == Array
      jobs.each do |job_info|
        parse_and_create_job_posting(job_info, google_api_service)
      end
    elsif jobs.class == Hash
      parse_and_create_job_posting(jobs, google_api_service)
    end
  end

  def parse_and_create_job_posting(job_info, google_api_service)
    worknet_id = job_info.dig("wantedAuthNo")
    return if ScrapedWorknetJobPosting.find_by(original_id: worknet_id)

    job_detail_info = WorknetApiService.call(1, "D", worknet_id).dig("wantedDtl")
    return if job_detail_info.dig("messageCd") == "006"

    business_info = job_detail_info.dig("corpInfo")
    job_posting_info = job_detail_info.dig("wantedInfo")
    emcharge_info = job_detail_info.dig("empchargeInfo")

    title = text_converter(job_posting_info.dig("wantedTitle"))
    description = text_converter(job_posting_info.dig("jobCont"))

    work_hour_type_text = job_posting_info.dig("workdayWorkhrCont")

    work_type = get_work_type(title, description, job_info.dig("jobsCd"), work_hour_type_text)
    working_hours_type = get_working_hours_type(work_hour_type_text)

    work_start_time = nil
    work_end_time = nil
    hours_text = nil
    if working_hours_type == 'normal' && work_type != "resident"
      begin
        start_time_arr, end_time_arr = get_hours_values(job_posting_info.dig("workdayWorkhrCont")&.split(", ")[0])
        work_start_time = "#{start_time_arr[0] > 9 ? start_time_arr[0] : "0#{start_time_arr[0]}"}:#{start_time_arr[1] > 9 ? start_time_arr[1] : "0#{start_time_arr[1]}"}"
        work_end_time = "#{end_time_arr[0] > 9 ? end_time_arr[0] : "0#{end_time_arr[0]}"}:#{end_time_arr[1] > 9 ? end_time_arr[1] : "0#{end_time_arr[1]}"}"
        hours_text = "#{work_start_time}~#{work_end_time}"
      rescue => e
        hours_text = job_posting_info.dig("workdayWorkhrCont")
      end
    end

    days_text = job_info.dig("holidayTpNm")

    address = job_info.dig("basicAddr")
    detail_address = job_info.dig("detailAddr")

    full_address = address

    if detail_address && !%w[0 , . .. ... .... ..... ....... - * ** *** **** ***-***].include?(detail_address)
      full_address = address + ", " + detail_address
    end

    coords = NaverApi.coords_from_address(address)
    coords = NaverApi.coords_from_address(address.split.uniq.join(' ')) if coords.dig(:lat).nil?

    pay_text = get_pure_pay_text(job_posting_info.dig("salTpNm"))
    begin
      payload = {
        original_id: worknet_id,
        url: job_info.dig("wantedInfoUrl"),
        mobile_url: job_info.dig("wantedMobileInfoUrl"),
        info: {
          center_name: business_info.dig("corpNm"),
          center_address: business_info.dig("corpAddr"),
          center_worker_count: business_info.dig("totPsncnt"),
          canter_president_name: business_info.dig("reperNm"),
          center_business_number: job_info.dig("busino"),
          title: title,
          period_type: job_posting_info.dig("empTpCd"),
          days_text: days_text,
          hours_text: hours_text,
          work_start_time: work_start_time,
          work_end_time: work_end_time,
          address: full_address,
          pay_text: pay_text,
          pay_type: get_pay_type(job_posting_info.dig("salTpCd")),
          working_hours_type: working_hours_type,
          welfare_text: job_posting_info.dig("etcWelfare"),
          description: description,
          latitude: coords.present? ? coords[:lat].to_f : nil,
          longitude: coords.present? ? coords[:lng].to_f : nil,
          contact_tel: emcharge_info.dig("contactTelno"),
          fax_number: emcharge_info.dig("chargerFaxNo"),
          applying_deadline: job_info.dig("closeDt"),
          welfares: job_posting_info.dig("etcWelfare")&.split(", "),
          jobs_code: work_type,
          grade: get_grade(title, description),
          gender: get_gender(title, description),
          min_wage: job_info.dig("minSal"),
          max_wage: job_info.dig("maxSal"),
          region: job_info.dig("region")
        }
      }

      payload[:info][:qualifications] = [
        %w[enterTpNm 경력조건],
        %w[eduNm 학력],
        %w[empTpNm 고용형태],
        %w[collectPsncnt 모집인원],
        %w[workRegion 근무예정지]
      ].select { |arr| job_posting_info.dig(arr[0]).present? }
       .map { |arr|
         {
           name: arr[1],
           value: job_posting_info.dig(arr[0])
         }
       }

      keyword_list = job_posting_info.dig("keywordList")
      work_keywords = nil
      if keyword_list.present?
        if keyword_list.class == Array
          work_keywords = keyword_list.map {|kwd| kwd.dig("srchKeywordNm")}.join(", ")
        else keyword_list.class == Hash
        work_keywords = keyword_list.dig("srchKeywordNm")
        end
      end

      payload[:info][:occupation_infos] = [
        {
          name: "모집직종",
          value: WorknetApiService::JOB_CODE[job_posting_info.dig("jobsCd").to_sym]
        },
        {
          name: "직종키워드",
          value: work_keywords
        },
        {
          name: "관련직종",
          value: job_posting_info.dig("relJobsNm")
        }
      ]

      payload[:info][:working_conditions] =  [
        {
          name: "임금조건",
          value: job_posting_info.dig("salTpNm")
        },
        {
          name: "근무시간",
          value: hours_text
        },
        {
          name: "근무형태",
          value: days_text
        },
        {
          name: "사회보험",
          value: job_posting_info.dig("fourIns")
        },
        {
          name: "퇴직급여",
          value: job_posting_info.dig("retirepay")
        }
      ]

      attach_list =  job_posting_info.dig("corpAttachList")
      attach_file_info = "등록된 파일이 없습니다."

      if attach_list.present?
        if attach_list.class == Array
          attach_file_info = "#{attach_list.count}개의 파일이 있습니다."
        elsif attach_list.class == Hash
          attach_file_info = "1개의 파일이 있습니다."
        end
      end
      payload[:info][:applying_info] = [
        %w[receiptCloseDt 접수마감일],
        %w[selMthd 전형방법],
        %w[rcptMthd 접수방법],
        %w[submitDoc 제출서류준비물],
      ].select { |arr| job_posting_info.dig(arr[0]).present? }
       .map { |arr|
         {
           name: arr[1],
           value: job_posting_info.dig(arr[0])
         }
       }
      payload[:info][:applying_info] = [
        *payload[:info][:applying_info],
        {
          name: "제출서류양식",
          value: attach_file_info
        }
      ]
      payload[:published_at] = DateTime.parse(job_info.dig("smodifyDtm") + "+0900")

      scraped_worknet_job_posting = ScrapedWorknetJobPosting.create!(payload)
      build_job_posting(
        scraped_worknet_job_posting,
        business_info,
        google_api_service
      )

      Jets.logger.info '[ActiveJob] Get Worknet Job Successfully'
    rescue => e
      puts Jets.logger.info "[Failed] Worknet api create job failed: #{e.message}"
    end
  end

  def build_job_posting(worknet_job, business_info, google_api_service)
    return if worknet_job.job_posting.present?
    return if worknet_job.closed?

    worknet_job_info = worknet_job.info
    business_number = worknet_job_info.dig("center_business_number")

    business = Business.find_by(business_number: business_number)
    if business.blank?
      business =
        Business.create(
          name: worknet_job_info.dig("center_name"),
          address: worknet_job_info.dig("center_address"),
          tel_number: worknet_job_info.dig("contact_tel"),
          fax_number: worknet_job_info.dig("fax_number"),
          business_number: business_number,
          worker_count:
            worknet_job_info.dig("center_worker_count").present? &&
              worknet_job_info.dig("center_worker_count")[/[^\d]*(\d+).*/, 1].to_i,
          info: {
            capital_amount: business_info.dig("capitalAmt"),
            year_sales_amount: business_info.dig("yrSalesAmt"),
            homepage_url: business_info.dig("homePg"),
            business_size: business_info.dig("busiSize")
          }
        )
    end

    job_posting = worknet_job.create_job_posting!(
      {
        business: business,
        title: worknet_job_info.dig("title"),
        address: worknet_job_info.dig("address"),
        description: worknet_job_info.dig("description"),
        lat: worknet_job_info.dig("latitude"),
        lng: worknet_job_info.dig("longitude"),
        gender: worknet_job_info.dig("gender"),
        grade: worknet_job_info.dig("grade"),
        published_at: worknet_job.published_at,
        min_wage: worknet_job_info.dig("min_wage"),
        max_wage: worknet_job_info.dig("max_wage"),
        work_start_time: worknet_job_info.dig("work_start_time"),
        work_end_time: worknet_job_info.dig("work_end_time"),
        status: worknet_job.status,
        work_type: worknet_job_info.dig("jobs_code"),
        pay_type: worknet_job_info.dig("pay_type"),
        working_hours_type: worknet_job_info.dig("working_hours_type"),
        region: worknet_job_info.dig("region")
      },
    )
    google_api_service.call("https://www.carepartner.kr/jobs/" + job_posting.public_id) if Jets.env.production? &&  google_api_service.present?
    job_posting
  end

  def get_work_type(title, description, jobs_code, work_hour_type_text)
    if work_hour_type_text.match?(/입주/)
      "resident"
    elsif work_hour_type_text.match?(/데이케어/)
      "day_care"
    else
      case jobs_code
      when "550100"
        matched_yes = false
        facility_candidates = [/요양원/, /주간보호/, /주야간/, /실버타운/, /시설/]
        facility_candidates.filter do |candidate|
          matched_yes = title.match?(candidate)
          matched_yes = description.match?(candidate) unless matched_yes
          break if matched_yes
        end
        matched_yes ? "facility" : "commute"
      when "550102", "550104"
        "commute"
      when "550103"
        "facility"
      else
        "commute"
      end
    end
  end

  def get_working_hours_type(work_hour_type_text)
    if work_hour_type_text.match?(/2교대/)
      "two_shift"
    elsif work_hour_type_text.match?(/3교대/)
      "three_shift"
    else
      "normal"
    end
  end

  def get_pay_type(pay_code)
    case pay_code
    when "D"
      "daily"
    when "H"
      "hourly"
    when "M"
      "monthly"
    when "Y"
      "yearly"
    else
      "hourly"
    end
  end

  def get_hours_values(raw_hours_text)
    start_text, end_text = raw_hours_text.split("~")
    end_text = end_text.split("분")&.first
    if raw_hours_text.match?(/시/) && raw_hours_text.match?(/분/)
      start_hour, start_min = start_text.split("시").map { |el| el.tr("^0-9", '').to_i }
      end_hour, end_min = end_text.split("시").map { |el| el.tr("^0-9", '').to_i }
    else
      start_text = start_text.split.last
      end_text = end_text.split.first
      start_hour, start_min = start_text.split(":").map { |el| el.tr("^0-9", '').to_i }
      end_hour, end_min = end_text.split(":").map { |el| el.tr("^0-9", '').to_i }
    end

    start_hour += 12 if start_text.match?(/오후/) || (start_text.match?(/자정/))
    end_hour += 12 if end_text.match?(/오후/) || (end_text.match?(/자정/))

    [
      [start_hour, start_min],
      [end_hour, end_min]
    ]
  end

  def get_pure_pay_text(raw_pay_text)
    pay_text = raw_pay_text.sub("이상,", "이상").sub("이하,", "이하")
    if pay_text.include?("이상") && pay_text.include?("~")
      pay_text = pay_text.sub(" 이상", "").sub(" 이하", "")
    end
    pay_text
  end

  def get_grade(title, description)
    grade = "none"
    if title.present? || description.present?
      grade =
        title&.match(/(?<grade>\d)등급/)&.[](:grade) ||
          description&.match(/(?<grade>\d)등급/)&.[](:grade)
      grade = grade.to_i if grade.present?
    end
    grade
  end

  def get_gender(title, description)
    gender = nil

    if [/할머니/, /여자/].filter do |w|
      title&.match(w) || description&.match(w)
    end.present?
      gender = 'female'
    end

    if [/할아버지/, /남자/].filter do |w|
      title&.match(w) || description&.match(w)
    end.present?
      gender = 'male'
    end

    gender
  end

  def text_converter(text)
    text&.gsub("\r\n", "\n")
      &.gsub("&nbsp;", " ")
      &.gsub("&lt;", "<")
      &.gsub("&gt;", ">")
      &.gsub("&amp;", "&")
      &.gsub("&quot;", '"')
      &.gsub("&#035;", '#')
      &.gsub("&#039;", "'")
  end
end