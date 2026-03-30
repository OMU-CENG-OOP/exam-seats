require_relative 'exam_notification_system'
require 'time'
#require_relative, require ve load farkları
puts "=== SISTEM BASLATILIYOR ==="

# 1. Öğrenci directory yükle
student_directory = StudentDirectory.new("students.csv")
puts "Student directory yuklendi."

# 2. Dersleri karıştır ve salonlara dağıt
shuffler = CourseRosterShuffler.new("courses.yml")

# salon kapasitesi
salons = {
  "Z02" => 108,
  "Z05" => 48,
  "Z07" => 36,
  "Z08" => 36,
  "Z09" => 36
}

puts "\n=== DERS LISTELERI KARISTIRILIYOR VE SALON DAGITIMI YAPILIYOR ==="
shuffler.shuffle_and_distribute_all(salons)

# 3. Sınav programını yükle
schedule = ExamSchedule.new("exam_schedule.yml")

# 4. Notification servisi
notifier = NotificationService.new(student_directory)

# 5. Runner
runner = ExamTriggerRunner.new(schedule, notifier)

# 6. TEST ZAMANI (manuel tetikleme)
test_time = Time.parse("2026-04-06 08:30")  # 09:00 sınavı için 30 dk önce

puts "\n=== TEST CALISIYOR ==="
puts "Simule edilen zaman: #{test_time}"

runner.run(test_time)

puts "\n=== SISTEM BITTI ==="
