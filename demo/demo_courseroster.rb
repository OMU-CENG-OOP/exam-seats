require_relative '../lib/courserostershuffler'

puts "Sistem Başlatiliyor..."
shuffler = CourseRosterShuffler.new

# Bütün dosyaları yaml dosyasından okuyup sisteme yükler
puts "Dersler yükleniyor..."
shuffler.load_courses("YAMLs/courses.yml") 

# İŞTE BURASI: Bütün dersleri tek komutla sırayla işleme sokar
puts "Tüm listeler kariştiriliyor ve salonlara dağitiliyor..."
shuffler.shuffle_all

puts "İşlem Tamamlandi!"