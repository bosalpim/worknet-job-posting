class VirtualNumber < ApplicationRecord
  USAGE_YOBOSA = :yobosa
  USAGE_CENTER = :center

  default_scope { order(:vn) }

  enum usage: {
    yobosa: 'yobosa',
    center: 'center'
  }

  validates :vn, presence: true, uniqueness: true
  
  scope :kct, -> { where(provider: 'kct') }
  scope :bizcall, -> { where(provider: nil) }
  scope :used, -> { where.not(rn: nil) }
  scope :not_used, -> { where(rn: nil) }
  scope :prod, -> { where(env: 'production') }
  scope :stag, -> { where(env: 'staging') }
  scope :dev, -> { where(env: 'development') }
  scope :expired_proposal_vn, -> {
    where(memo: [BizcallCallback::BUSINESS_SEND, BizcallCallback::USER_SEND_BY_PROPOSAL]).where('updated_at < ?', 5.days.ago)
  }

  def self.left_prod_vn_count
    prod.not_used.size
  end

  def self.next
    # 가상번호 할당하는 우선순위
    #
    # 1. 사용하지 않은 것 중에 하나
    vn = if Rails.env.production?
           prod.bizcall.not_used.first
         elsif Rails.env.staging?
           stag.bizcall.not_used.first
         else
           dev.bizcall.not_used.first
         end

    # 2. 제안 시, 요보사 -> 기관으로 바로 전화 시 사용하는 번호 중 만료된 것 중 하나
    vn = bizcall.expired_proposal_vn.first if vn.nil?

    # 3. 할당된 후 가장 오래된 가상번호 하나
    vn = bizcall.find_new_or_oldest_updated if vn.nil?

    vn
  end

  def self.next_vns(usage = USAGE_YOBOSA)
    vn = if Rails.env.production?
           prod.kct.try(usage).not_used.first
         elsif Rails.env.staging?
           stag.kct.try(usage).not_used.first
         else
           dev.kct.try(usage).not_used.first
         end

    # 2. 제안 시, 요보사 -> 기관으로 바로 전화 시 사용하는 번호 중 만료된 것 중 하나
    vn = kct.try(usage).expired_proposal_vn.first if vn.nil?

    # 3. 할당된 후 가장 오래된 가상번호 하나
    vn = kct.try(usage).find_new_or_oldest_updated if vn.nil?

    vn
  end

  def self.find_new_or_oldest_updated
    if Rails.env.production?
      prod.not_used.first.nil? ? prod.reorder(updated_at: "asc").first! : prod.not_used.first
    elsif Rails.env.staging?
      stag.not_used.first.nil? ? stag.reorder(updated_at: "asc").first! : stag.not_used.first
    else
      dev.not_used.first.nil? ? dev.reorder(updated_at: "asc").first! : dev.not_used.first
    end
  end
end
