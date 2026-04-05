require 'blablabla'

# Gercek mail yerine ekrana bildirim basar.
# Ders CSV'sinin daha once karistirilip su alanlari icermesi beklenir:
# student_no,salon,seat_no,global_order
class NotificationService
  def initialize(student_directory)
    @student_directory = student_directory
  end

  def notify_exam_students(exam)

  end

  private

  def notification_message(student_no:, name:, surname:, course_name:, salon:, seat_no:, email:)

  end
end
