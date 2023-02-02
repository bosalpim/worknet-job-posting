class KakaoTemplateService
  attr_reader :template_id

  def initialize(template_id)
    @template_id = template_id
  end

  private

  def get_template_data(template_id, tem_params)
    case template_id
    when "proposal_02"
      proposal_02(tem_params)
    else
      # Sentry.capture_message("존재하지 않는 메시지 템플릿 요청입니다: template_id: #{template_id}, tem_params: #{tem_params.to_json}")
    end
  end

  def proposal_02(tem_params)
    items = {
      itemHighlight: {
        title: "#{tem_params[:user_name]}님! 채용제안을 받으신 기관에 전화해보세요",
        description: '인기공고는 빠르게 마감됩니다.'
      },
      item: {
        list: [
          {
            title: '센터명',
            description: tem_params[:business_name]&.truncate(19) || ""
          },
          {
            title: '거리',
            description: tem_params[:distance]
          },
          {
            title: '근무지',
            description: tem_params[:address]&.truncate(19) || ""
          },
          {
            title: '근무유형',
            description: tem_params[:work_type_ko]
          },
          {
            title: '임금조건',
            description: tem_params[:pay_text]&.truncate(19) || ""
          },
        ],
        summary: ""
      }
    }
    {
      title: "#{tem_params[:user_name]}님, 가까운 센터에서 일자리를 제안했어요!",
      message: "#{tem_params[:user_name]}님! 근처의 #{tem_params[:business_name]}에서\n일자리를 제안했습니다.\n\n본 공고에 취업성공 하시면,\n케어파트너에서 50,000원의 추가수당을 드려요!\n\n센터번호: #{good_number(tem_params[:business_vn])}\n[ 빠르게 연락 하실수록 취업 가능성이 높아져요 ]",
      img_url: "https://mud-kage.kakao.com/dn/btfYkj/btrXIoI2ckc/85jhQdX5TuqNEdfrfBXgX0/img_l.jpg",
      items: items,
      buttons: [
        {
          name: "채용공고 확인하기",
          type: "WL",
          url_pc: "https://carepartner.kr/jobs/#{tem_params[:job_posting_public_id]}?proposal=true",
          url_mobile: "https://carepartner.kr/jobs/#{tem_params[:job_posting_public_id]}?proposal=true"
        },
      ]
    }
  end

  def good_number(phone_number)
    if phone_number&.length == 12
      phone_number&.scan(/.{4}/)&.join('-')
    else
      phone_number&.slice(0, 3) + "-" +  phone_number&.slice(3..)&.scan(/.{4}/)&.join('-') rescue nil
    end
  end
end