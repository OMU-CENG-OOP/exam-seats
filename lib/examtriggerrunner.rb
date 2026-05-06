# Zamani gelen sinavlar icin bildirim akisini calistirir.
class ExamTriggerRunner
  def initialize(exam_schedule, notification_service)
    @exam_schedule = exam_schedule
    @notification_service = notification_service
  end

  def run(current_time)
    unless @notification_service.respond_to?(:notify)
      raise ArgumentError, 'notification_service nesnesi notify(exam) metodunu saglamalidir.'
    end

    due_exams = @exam_schedule.due_exams(current_time)

    due_exams.each do |exam|
      @notification_service.notify(exam)
    end

    due_exams
  end
end
