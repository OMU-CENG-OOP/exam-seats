

# Zamani gelen sinavlar icin bildirim akisini calistirir.
class ExamTriggerRunner
  def initialize(exam_schedule, notification_service)
    @exam_schedule = exam_schedule
    @notification_service = notification_service
    @triggered_exams = []
    
  end

  def run(current_time)
    verify_notification_capability!

    candidate_exams = @exam_schedule.due_exams(current_time)
    trigger_notifications(candidate_exams, current_time)
  end


private 

  def verify_notification_capability!
    unless @notification_service.respond_to?(:notify)
      raise ArgumentError, 'notification_service nesnesi notify(exam) metodunu saglamalidir.'
    end
  end

  def trigger_notifications(exams, current_time)
    exams.each do |exam|
      if should_send_notification?(exam, current_time)
        send_notifications(exam)
      end
    end      
  end

  def should_send_notification?(exam, current_time)
    return false if @triggered_exams.include?(exam.object_id)
    current_time >= exam.trigger_time && current_time < exam.exam_datetime
  end

  def send_notifications(exam)
    @notification_service.notify(exam)
    @triggered_exams << exam.object_id 
  end

end