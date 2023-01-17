class WorknetApiService
  include ExtendedHttparty

  JOB_CODE = {
    "550100": "요양보호사 및 간병인",
    "550102": "재가 간병인",
    "550103": "시설 요양보호사(노인요양사)",
    "550104": "재가 요양보호사"
  }.freeze
  CERT_CODE = {
    "6099768": "요양보호사",
    "6003435": "요양보호사",
    "6005924": "요양보호사 1급",
    "6010015": "요양보호사 1급",
    "6005925": "요양보호사 2급",
    "6010016": "요양보호사 2급",
  }.freeze

  def self.call(
    start_page = 1,
    call_type = "L",
    wanted_auth_no = nil,
    display = 100,
    reg_date = "D-0",
    occupation = JOB_CODE.keys.map {|code| code.to_s}.join("|"), # 요양보호사 직종코드
    cert =  CERT_CODE.keys.map {|code| code.to_s}.join("|") # 요양보호사 자격면허 코드
  )
    new(start_page, call_type, wanted_auth_no, display, reg_date, occupation, cert).call
  end

  def initialize(
    start_page,
    call_type,
    wanted_auth_no,
    display,
    reg_date,
    occupation,
    cert
  )
    @base_url =
      "http://openapi.work.go.kr/opi/opi/opia/wantedApi.do?authKey=#{ENV['WORKNET_API_KEY']}&returnType=XML"
    @start_page = start_page
    @call_type = call_type
    @wanted_auth_no = wanted_auth_no
    @display = display
    @reg_date = reg_date
    @occupation = occupation
    @cert = cert
  end

  def call
    get_job_postings
  end

  private

  attr_reader :base_url, :call_type, :wanted_auth_no, :start_page, :display, :reg_date, :occupation, :cert

  def get_job_postings
    ExtendedHttparty.get(target_url, verify: true)
  end

  def target_url
    result_url = base_url
    result_url += "&startPage=#{start_page}" if start_page && call_type != "D"
    result_url += "&callTp=#{call_type}" if call_type
    result_url += "&wantedAuthNo=#{wanted_auth_no}" if wanted_auth_no && call_type != "L"
    result_url += "&display=#{display}" if display && call_type != "D"
    result_url += "&regDate=#{reg_date}" if reg_date && call_type != "D"
    result_url += "&occupation=#{occupation}" if occupation && call_type != "D"
    # result_url += "&certLic=#{cert}" if cert && call_type != "D"
    result_url += "&infoSvc=VALIDATION" if call_type == "D"
    result_url
  end
end