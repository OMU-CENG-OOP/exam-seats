require_relative 'lib/courserostershuffler'
require_relative 'lib/exam'
require_relative 'lib/examschedule'
require_relative 'lib/examtriggerrunner'
require_relative 'lib/notificationservice'
require_relative 'lib/studentdirectory'

require 'time'
#require_relative, require ve load farklarina bakiniz
puts "=== SISTEM BASLATILIYOR ==="

# 1. Ogrenci directory yukle
student_directory = StudentDirectory.new("Lists/Whole Students.csv")
puts "Student directory <ogrenci_no> <mail_address> yuklendi."

# 2. Dersleri karistir ve salonlara dagit
shuffler = CourseRosterShuffler.new("YAMLs/courses.yml")

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

# 3. Sinav programini yukle
schedule = ExamSchedule.new("/YAMLs/exam_schedule.yml")

# 4. Notification (Bildirim) servisi
# `config`, secilen bildirici kanalinin ayarlarini tasir.
notifier = ConsoleNotificationService.new(student_directory, config: {})

# 4. Gelecek icin alternatif bildiriciler:
# notifier = SlackNotificationService.new(student_directory, config: {})
# notifier = GmailChatNotificationService.new(student_directory, config: {})
# notifier = DiscordNotificationService.new(student_directory, config: {})
# notifier = SmsNotificationService.new(student_directory, config: {})

# 5. Runner
runner = ExamTriggerRunner.new(schedule, notifier)

# 6. TEST ZAMANI (manuel tetikleme)
test_time = Time.parse("2026-04-06 08:30")  # 09:00 sınavı için 30 dk önce

puts "\n=== TEST CALISIYOR ==="
puts "Simule edilen zaman: #{test_time}"

runner.run(test_time)

puts "\n=== SISTEM BITTI ==="
