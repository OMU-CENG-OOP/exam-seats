require 'date'
require_relative '../lib/exam'                 
require_relative '../lib/examschedule'         
require_relative '../lib/examtriggerrunner'

# 1. Sahte (Mock) Bildirim Servisi
class TerminalNotificationService
  def notify(exam)
    puts " [SİSTEM BİLDİRİMİ]: #{exam.course_name} sinaviniz #{exam.time} saatinde başlayacaktir! Lütfen salonunuza geçiniz."
  end
end

puts "--- Orkestratör Testi Başliyor ---\n\n"

# 2. Takvimi ve Sınavları Hazırla
schedule = ExamSchedule.new
# BIL101: 14:00'te sınav, 30 dk önce bildirim (13:30'da tetiklenmeli)
sinav1 = Exam.new("BIL101", "2026-10-20", "14:00", 30)
# MAT101: 16:00'da sınav, 60 dk önce bildirim (15:00'da tetiklenmeli)
sinav2 = Exam.new("MAT101", "2026-10-20", "16:00", 60)

schedule.add_exam(sinav1)
schedule.add_exam(sinav2)

# 3. Yöneticileri (Runner ve Servis) Başlat
notifier = TerminalNotificationService.new
runner = ExamTriggerRunner.new(schedule, notifier)

# 4. ZAMAN SİMÜLASYONU
puts " Senaryo 1: Saat 13:15 (Erken - Hiçbir bildirim gitmemeli)"
zaman_1 = DateTime.parse("2026-10-20 13:15")
runner.run(zaman_1)
puts "✔️ Sonuç: Tetiklenme olmadi.\n\n"

puts " Senaryo 2: Saat 13:35 (BIL101 için zaman geldi!)"
zaman_2 = DateTime.parse("2026-10-20 13:35")
runner.run(zaman_2)
puts "\n"

puts " Senaryo 3: Saat 13:40 (Spam Kontrolü - BIL101 bildirimi TEKRAR GİTMEMELİ)"
zaman_3 = DateTime.parse("2026-10-20 13:40")
runner.run(zaman_3)
puts "✔️ Sonuç: Spam filtresi çalişti, ikinci mesaj atilmadi.\n\n"

puts " Senaryo 4: Saat 15:05 (MAT101 için 60 dk önceden bildirim zamani geldi!)"
zaman_4 = DateTime.parse("2026-10-20 15:05")
runner.run(zaman_4)
puts "\n--- Test Tamamlandi ---"