require 'date'
require_relative '../lib/exam'
require_relative '../lib/examschedule'

puts "--- Zaman Testi Başliyor ---\n\n"

# 1. Boş bir sınav yöneticisi oluştur
schedule = ExamSchedule.new

# 2. Test için sahte sınavlar ekle
# Sınav 1: Bugün saat 14:00'te, 30 dk önceden bildirim (Tetiklenme: 13:30)
sinav1 = Exam.new("BIL101", "2026-10-20", "14:00", 30)

# Sınav 2: Bugün saat 16:00'da, 60 dk önceden bildirim (Tetiklenme: 15:00)
sinav2 = Exam.new("MAT101", "2026-10-20", "16:00", 60)

# Sınav 3: Yarın saat 10:00'da, 30 dk önceden bildirim (Tetiklenme: Ertesi gün 09:30)
sinav3 = Exam.new("FIZ101", "2026-10-21", "10:00", 30)

schedule.add_exam(sinav1)
schedule.add_exam(sinav2)
schedule.add_exam(sinav3)

# 3. Sahte bir "Şu Anki Zaman" (Current Time) belirle
# Diyelim ki şu an saat tam 13:45
sahte_zaman = DateTime.parse("2026-10-20 13:45")

puts "Şu anki simüle edilen zaman: #{sahte_zaman.strftime('%H:%M')}"
puts "Sistem kontrol ediliyor...\n\n"

# 4. due_exams fonksiyonunu çalıştır
zamani_gelenler = schedule.due_exams(sahte_zaman)

if zamani_gelenler.empty?
  puts "Şu an için bildirim gönderilecek sinav yok."
else
  puts "🚨 Bildirim Gönderilmesi Gereken Sinavlar:"
  zamani_gelenler.each do |exam|
    puts "- #{exam.course_name} (Sınav Saati: #{exam.time}, Tetiklenme: #{exam.trigger_time.strftime('%H:%M')})"
  end
end