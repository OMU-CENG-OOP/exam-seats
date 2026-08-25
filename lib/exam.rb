require 'date'

# Tek bir sinavi temsil eder.
# exam_schedule.yml beklenen alanlar:
# course_name, date, time
class Exam
  attr_accessor :course_name, :date, :time, :notification_offset

  def initialize(course_name, date, time, notification_offset = 30)
    @course_name = course_name
    @date = date
    @time = time
    @notification_offset = notification_offset.to_i
  end

  def exam_datetime
    DateTime.parse("#{@date} #{@time}")
  end

  def trigger_time
    exam_datetime - Rational(@notification_offset, 1440)
  end
  
end