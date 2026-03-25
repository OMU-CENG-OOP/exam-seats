# Sınav Bildirim Sistemi - Temel Tasarım Dokümanı

Bu dosyada anlatılan yapı, Ruby dili ile geliştirilecek basit bir sınav oturma planı ve bildirim iskeletini oluşturmaktadır.

Sistemde dört ana işi bulunmaktadır:

1. `students.csv` dosyasından tüm bölüm öğrencilerinin bilgilerini belleğe alma,
2. `courses.yml` dosyasından ders adlarını okuma,
3. Her ders için `<course_name>.csv` dosyasını karıştırma, öğrencileri tanımlı salon kapasitelerine göre dağıtma ve aynı dosyaya tekrar kaydetme,
4. `exam_schedule.yml` dosyasındaki sınav saatlerini takip etme; sınavdan 30 dakika önce ilgili öğrencilere bildirim üretme. Şimdilik gerçek e-posta yerine sadece ekrana yazdırılmalıdır.

---

## 1. Sınıflar ve Sorumlulukları

### StudentDirectory
Amaç: `students.csv` dosyasını okuyup öğrenci numarasına göre isim, soyisim ve e-posta bilgilerini bellekte tutmak.

Beklenen CSV biçimi:

```csv
student_no,name,surname,email
2301001,Ali,Yilmaz,ali@example.com
2301002,Ayse,Demir,ayse@example.com
```

Temel davranışlar:
- CSV'den veriyi yükler.
- `student_no` ile öğrenci bilgisi döndürür.

---

### CourseRosterShuffler
Amaç: `courses.yml` dosyasındaki dersleri okuyup her dersin CSV listesini karıştırmak, sonra öğrencileri salon kapasitelerine göre paylaştırmak ve dosyayı güncellemek.

Varsayılan salon kapasitesi bilgisi:

- Z02: 108 kişi
- Z05: 48 kişi
- Z07: 36 kişi
- Z08: 36 kişi
- Z09: 36 kişi

Toplam kapasite: 264 kişi

Beklenen ders CSV giriş biçimi:

```csv
student_no
2301001
2301002
2301003
```

Karıştırma ve dağıtım sonrası aynı dosya şu biçime dönüşür:

```csv
student_no,salon,seat_no,global_order
2301050,Z02,1,1
2301012,Z02,2,2
2301091,Z02,3,3
...
2301198,Z05,1,109
```

Dağıtım mantığı:
- Liste önce rastgele karıştırılır.
- Sonra verilen salon sırasına göre doldurulur.
- Önce Z02 dolar, sonra Z05, sonra Z07, sonra Z08, sonra Z09.
- `seat_no`, ilgili salon içindeki sıra numarasıdır.
- `global_order`, tüm karıştırılmış listedeki genel sıradır.

---

### Exam
Amaç: Tek bir sınavı temsil etmek.

Alanlar:
- `course_name`
- `date`
- `time`

Davranışlar:
- Sınavın gerçek tarih-saat bilgisini üretir.
- Bildirim için `trigger_time = sınav zamanı - 30 dakika` hesabını yapar.

---

### ExamSchedule
Amaç: `exam_schedule.yml` dosyasını okuyup tüm sınavları belleğe almak.

Örnek YML:

```yml
exams:
  - course_name: BLM101
    date: 2026-03-30
    time: "10:00"
  - course_name: MAT103
    date: 2026-03-30
    time: "14:00"
```

Davranışlar:
- YML'den sınav listesi oluşturur.
- Belirli anda tetiklenmesi gereken sınavları döndürür.

---

### NotificationService
Amaç: Sınavı yaklaşan dersin karıştırılmış CSV listesini okuyup öğrenciye özel bildirim metni üretmek.

Kullandığı veri kaynakları:
- `StudentDirectory` içindeki öğrenci adı, soyadı, e-posta bilgisi
- `<course_name>.csv` içindeki salon ve sıra bilgisi

Örnek çıktı:

```text
Sayın 2301001 nolu ogrencimiz Ali Yilmaz, BLM101 dersinizin sinavina 30 dk. sonra Z02 salonunda 17 sirasinda oturma plani yapilmistir. Sinavinizda basarilar dileriz.
```

---

### ExamTriggerRunner
Amaç: O an tetik zamanı gelmiş sınavları bulmak ve bildirim servisini çalıştırmak.

Akış:
- `ExamSchedule` üzerinden zamanı gelen sınavları bulur.
- Her sınav için `NotificationService` çağrılır.

---

## 2. Sınıflar Arası İlişki

İlişki özeti:

- `StudentDirectory` → öğrenci rehberi sağlar.
- `CourseRosterShuffler` → ders öğrenci listesini karıştırır ve salonlara dağıtır.
- `ExamSchedule` → sınav takvimini tutar.
- `Exam` → tek bir sınavdır.
- `NotificationService` → öğrenci rehberi + ders oturma planı verisini kullanarak bildirim oluşturur.
- `ExamTriggerRunner` → zamanı gelen sınavlar için bildirim sürecini başlatır.

Basit akış:

```text
students.csv  ---> StudentDirectory
courses.yml   ---> CourseRosterShuffler ---> BLM101.csv / MAT103.csv güncellenir
exam_schedule.yml ---> ExamSchedule ---> Exam nesneleri

ExamTriggerRunner ---> NotificationService ---> ekrana bildirim basılır
```

---

## 3. Dosya Biçimleri

### students.csv

```csv
student_no,name,surname,email
2301001,Ali,Yilmaz,ali@example.com
2301002,Ayse,Demir,ayse@example.com
```

### courses.yml

```yml
courses:
  - BLM101
  - MAT103
```

### BLM101.csv (karıştırma öncesi)

```csv
student_no
2301001
2301002
2301003
```

### BLM101.csv (karıştırma sonrası)

```csv
student_no,salon,seat_no,global_order
2301002,Z02,1,1
2301003,Z02,2,2
2301001,Z02,3,3
```

### exam_schedule.yml

```yml
exams:
  - course_name: BLM101
    date: 2026-03-30
    time: "10:00"
```

---

## 4. İşleyiş Sırası

1. `students.csv` yüklenir.
2. `courses.yml` yüklenir.
3. Her dersin CSV dosyası karıştırılır.
4. Öğrenciler salonlara sırayla dağıtılır.
5. Yeni oturma planı aynı ders CSV dosyasına kaydedilir.
6. `exam_schedule.yml` yüklenir.
7. Çalışma zamanı, bir sınavın `trigger_time` değerine eşitse ilgili öğrenciler için bildirim üretilir.

---

## 5. Haftalık Geliştirme Planı

### Hafta 1
- `StudentDirectory`
- CSV okuma
- Hash içinde öğrenci bilgisi tutma

### Hafta 2
- `CourseRosterShuffler`
- Ders CSV dosyasını karıştırma
- Salonlara kapasiteye göre paylaştırma
- CSV'ye geri yazma

### Hafta 3
- `Exam` ve `ExamSchedule`
- YML okuma
- 30 dakika önce tetik zamanı hesabı

### Hafta 4
- `NotificationService`
- Öğrenci bilgisi + salon bilgisi ile bildirim metni üretme

### Hafta 5
- Menü
- gerçek e-posta
- hata kontrolleri
- loglama

---

## 6. Eksikler

Şu anki sürümde:
- gerçek e-posta gönderimi yoktur,
- zamanlayıcı servisi yoktur,
- tetikleme manuel `runner.run(Time.parse(...))` ile test edilir,
- sınıf listesi dosyalarında öğrenci numarası sütununun adı `student_no` olmalıdır.

---

## 7. Tetikleme Örneği

Örnek test:

```ruby
runner.run(Time.parse('2026-03-30 09:30'))
```

Bu çağrı, `2026-03-30 10:00` saatli sınav için 30 dakika öncesi tetikleme yapar.
