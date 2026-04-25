# Sınav Yerleşim ve Bildirim Sistemi

Bu proje, Ruby ile geliştirilen bir sınav yerleşim ve bildirim iskeletidir. Amaç; öğrenci listelerini salonlara dağıtmak, sınav takvimini belleğe almak ve zamanı gelen sınavlar için seçilen bildirim kanalı üzerinden duyuru göndermektir.

Kod tabanındaki bazı sınıflar özellikle şablon halinde bırakılmıştır. Öğrenciden beklenen, bu sınıfların içini verilen arayüze sadık kalarak doldurmasıdır.

## Ana Akış

`main.rb` içindeki hedef akış şöyledir:

```ruby
student_directory = StudentDirectory.new("Lists/Whole Students.csv")

shuffler = CourseRosterShuffler.new("YAMLs/courses.yml")
shuffler.shuffle_and_distribute_all(salons)

schedule = ExamSchedule.new("/YAMLs/exam_schedule.yml")

notifier = ConsoleNotificationService.new(student_directory, config: {})

runner = ExamTriggerRunner.new(schedule, notifier)
runner.run(test_time)
```

Bu akışta:

- `StudentDirectory` öğrenci rehberini sağlar.
- `CourseRosterShuffler` ders listelerini karıştırır ve salonlara dağıtır.
- `ExamSchedule` sınav takvimini yükler.
- `NotificationService` ailesinden seçilen bir servis bildirimi gönderir.
- `ExamTriggerRunner` zamanı gelen sınavları bulup bildirimi tetikler.

## Güncel Tasarım Kararları

### 1. `ExamSchedule` bellekte ne tutmalı?

`ExamSchedule` dosyayı okuduktan sonra ana veri yapısı olarak `Array<Exam>` tutmalıdır.

Önerilen iç durum:

```ruby
@source_path = "YAMLs/exam_schedule.yml"
@exams = [
  # Exam nesneleri
]
```

Bunun nedeni:

- `runner`, ham YAML hash'leriyle değil `Exam` nesneleriyle çalışmalıdır.
- `due_exams(current_time)` doğrudan `Exam` nesneleri döndürmelidir.
- `notifier.notify(exam)` çağrısı domain nesnesi üzerinden ilerlemelidir.

### 2. `ExamTriggerRunner` hangi arayüzü bekliyor?

`ExamTriggerRunner` iki bağımlılık alır:

```ruby
runner = ExamTriggerRunner.new(schedule, notifier)
```

Bu kullanıma göre beklenti şudur:

- `schedule` nesnesi `due_exams(current_time)` metodunu sağlamalıdır.
- `notifier` nesnesi `notify(exam)` metodunu sağlamalıdır.

Yani `runner`, sınıf adıyla değil ortak arayüzle ilgilenir.

### 3. Bildirim servisi nasıl genişletilir?

Temel tasarım kanal bağımsızdır:

- `NotificationService` taban sınıftır.
- `ConsoleNotificationService` ilk somut örnektir.
- İleride `SlackNotificationService`, `DiscordNotificationService`, `SmsNotificationService`, `GmailChatNotificationService` gibi alt sınıflar eklenebilir.

Her bildirici aynı ortak metodu sunmalıdır:

```ruby
notify(exam)
```

Bu sayede `runner`, aktif kanal ne olursa olsun değişmeden kalır.

## Sınıflar ve Beklenen Arayüzler

### `Exam`

Tek bir sınavı temsil eder.

Beklenen alanlar:

- `course_name`
- `date`
- `time`

Beklenen metodlar:

- `initialize(course_name, date, time)`
- `exam_datetime`
- `trigger_time`

Not:

- `trigger_time`, sınavdan önce bildirim gönderilecek anı hesaplamak için kullanılmalıdır.
- `notification_offset_minutes` gibi alanlar ileride bu hesapta dikkate alınabilir.

### `ExamSchedule`

Sınav takvimini yükleyen ve sorgulayan sınıftır.

Mevcut iskelet:

```ruby
class ExamSchedule
  attr_reader :exams, :source_path

  def initialize(file_path = nil)
  end

  def load_from_yml(file_path)
  end

  def due_exams(current_time)
  end

  def add_exam(exam)
  end

  def reload!
  end

  def empty?
  end
end
```

Beklenen sorumluluklar:

- YAML dosyasını okumak
- satırları ayrıştırmak
- her satırı `Exam` nesnesine dönüştürmek
- `@exams` dizisinde tutmak
- verilen anda tetiklenmesi gereken sınavları döndürmek

Özel yardımcı metodlar:

- `build_exam(exam_row)`
- `raw_exam_rows(yml_data)`

### `NotificationService`

Kanal bağımsız bildirim taban sınıfıdır.

Mevcut iskelet:

```ruby
class NotificationService
  attr_reader :student_directory, :lists_path, :config

  def initialize(student_directory, lists_path: 'Lists', config: {})
  end

  def notify(exam)
  end
end
```

Beklenen sorumluluklar:

- ilgili dersin CSV dosyasını okumak
- öğrenci numarasına göre rehberden öğrenci bilgisini çekmek
- bildirim payload'ı üretmek
- seçili kanala gönderim yapmak

`config` nedir?

- aktif bildirim kanalının ayarlarını taşır
- örnek: `webhook_url`, `token`, `channel_id`, `sender_id`

### `ConsoleNotificationService`

İlk somut kanal örneğidir.

Beklenen davranış:

- `channel_name` döndürmek
- `deliver(notification)` içinde mesajı ekrana basmak

### `ExamTriggerRunner`

Zamanı gelen sınavlar için bildirim akışını başlatır.

Mevcut arayüz:

```ruby
class ExamTriggerRunner
  def initialize(exam_schedule, notification_service)
  end

  def run(current_time)
  end
end
```

Beklenen davranış:

1. `schedule.due_exams(current_time)` çağrılır.
2. Dönen her `exam` için `notifier.notify(exam)` çağrılır.
3. İşlenen sınav listesi geri döndürülebilir.

### `StudentDirectory`

Öğrenci rehberini tutar.

Beklenen veri alanı:

```csv
student_no,email
2301199,can.kilic199@example.com
2301230,seda.dogan230@example.com
```

Beklenen metodlar:

- `load_from_csv(file_path)`
- `find(student_no)`

### `CourseRosterShuffler`

Ders listelerini karıştırıp salonlara dağıtan sınıftır.

Beklenen görevler:

- `courses.yml` içinden dersleri okumak
- ders CSV dosyalarını karıştırmak
- salon kapasitesine göre yerleşim yapmak
- sonucu tekrar CSV olarak kaydetmek

Beklenen yardımcı alanlar:

- `courses`
- `room_capacities`

## Dosya Biçimleri

### `YAMLs/exam_schedule.yml`

Örnek mevcut yapı:

```yml
exams:
  - course_name: Ayrik-Matematik
    date: '2026-04-06'
    time: '09:00'
    notification_offset_minutes: 30
  - course_name: Cizge-Kuram
    date: '2026-04-06'
    time: '13:00'
    notification_offset_minutes: 30
```

### `Lists/Whole Students.csv`

Projede şu anda kullanılan rehber dosyası `student_no,email` biçimindedir.

```csv
student_no,email
2301199,can.kilic199@example.com
2301230,seda.dogan230@example.com
```

### `Lists/<course_name>.csv`

Karıştırma öncesi:

```csv
student_no,name,surname
2301199,Can,Kilic
2301230,Seda,Dogan
```

Karıştırma sonrası hedef yapı:

```csv
student_no,salon,seat_no,global_order
2301199,Z02,1,1
2301230,Z02,2,2
```

## Bildirim Kanalları

`lib/notificationservice.rb` içinde yorum bloğu halinde gelecek için örnek şablonlar bırakılmıştır:

- `SlackNotificationService`
- `GmailChatNotificationService`
- `DiscordNotificationService`
- `SmsNotificationService`

Bu sınıflar şu amaçla yer alır:

- ortak arayüzü göstermek
- `config` kullanımını örneklemek
- öğrencinin gerçek entegrasyonu aynı iskelet üzerinde geliştirmesini sağlamak

## Geliştirme Notları

Bu proje şu anda tam bitmiş bir uygulama değil, yönlendirilmiş bir iskelettir.

Şu noktalar özellikle öğrenciye bırakılmıştır:

- YAML okuma ve `Exam` nesnesi üretimi
- `due_exams` mantığı
- öğrenci rehberi okuma
- bildirim mesajı üretimi
- gerçek Slack / Discord / SMS / Google Chat entegrasyonları

En önemli bağımlılık sözleşmeleri şunlardır:

- `ExamSchedule#due_exams(current_time)` -> `Array<Exam>`
- `NotificationService#notify(exam)` -> bildirimleri üretir ve gönderir
- `ExamTriggerRunner#run(current_time)` -> iki tarafı bağlar

Bu sözleşme korunduğu sürece alt sınıfların iç implementasyonu serbestçe geliştirilebilir.
