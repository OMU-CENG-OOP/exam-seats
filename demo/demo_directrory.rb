require 'csv'
require_relative '../lib/users' # Az önce oluşturduğumuz sınıfları dahil ediyoruz
require_relative '../lib/studentdirectory'

puts "--- StudentDirectory Testi Başlıyor ---\n\n"

# 1. Test için geçici bir CSV dosyası oluşturuyoruz
test_csv_path = "test_students.csv"
CSV.open(test_csv_path, "wb") do |csv|
  csv << ["student_no", "name", "surname", "email"]
  csv << ["123456", "Ali", "Yılmaz", "ali@example.com"]
  csv << ["654321", "Ayşe", "Kaya", "ayse@example.com"]
  # Bilerek numarada ve isimde boşluk bırakıyoruz ki .strip metodunu test edelim
  csv << ["  111222  ", " Mehmet ", " Demir", "mehmet@example.com"] 
end

puts " Geçici test dosyasi oluşturuldu (#{test_csv_path}).\n\n"

# 2. Rehberi başlat ve CSV'yi yükle
directory = StudentDirectory.new
directory.load_from_csv(test_csv_path)

puts " Rehber belleğe yüklendi. İçerideki öğrenci sayisi: #{directory.students_map.size}\n\n"

# 3. Arama Senaryoları
puts " Senaryo 1: Geçerli bir numarayi arama (123456)"
ogrenci1 = directory.find("123456")
if ogrenci1
  puts " Bulundu: #{ogrenci1.full_name} - #{ogrenci1.email}"
else
  puts " Hata: Öğrenci bulunamadi!"
end
puts "\n"

puts " Senaryo 2: Etrafinda boşluklar olan (özensiz girilmiş) bir numarayi arama"
# Kullanıcı web sitesindeki kutuya yanlışlıkla boşluklu yazarsa ne olur?
ogrenci2 = directory.find("  111222 ")
if ogrenci2
  puts " Bulundu ve temizlendi: #{ogrenci2.full_name} - #{ogrenci2.email}"
else
  puts "Hata: Öğrenci bulunamadi!"
end
puts "\n"

puts "🔍 Senaryo 3: Sistemde olmayan bir numarayi arama (999999)"
ogrenci3 = directory.find("999999")
if ogrenci3.nil?
  puts " Başarili: Olmayan öğrenci numarasi için sistem çökmedi, boş (nil) döndü."
else
  puts " Hata: Yanliş bir öğrenci nesnesi döndü!"
end
puts "\n"

# 4. Temizlik
File.delete(test_csv_path) if File.exist?(test_csv_path)
puts " Temizlik tamamlandi. Test bitti."