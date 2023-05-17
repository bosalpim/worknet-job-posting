module NewsPaper
  def self.get_today
    today = (Time.current + (9 * 60 * 60)).strftime("%-m월%d일")
    weekday = getWeekDay((Time.current + (9 * 60 * 60)).strftime("%w"))
    return today + " " + weekday
  end

  def self.getWeekDay(weekDayNumber)
    case weekDayNumber
    when "0"
      return "일요일"
    when "1"
      return "월요일"
    when "2"
      return "화요일"
    when "3"
      return "수요일"
    when "4"
      return "목요일"
    when "5"
      return "금요일"
    when "6"
      return "토요일"
    end
  end

  def self.find_target_user_by_csv(filename, job_search_status)
    f = File.open(filename,'r')
    data = f.read
    user_list = data.split("\r\n",1002).drop(1)
    user_list.delete_at(user_list.length - 1)
    users = User.where(id: user_list)
                .where(job_search_status: job_search_status)
                .where(has_certification: true)
                .where(notification_enabled: true)
                .active
    users
  end
end