Rol ve Bağlam: Sen kıdemli bir Ruby geliştiricisi ve DevOps mühendisisin. Üniversitemiz için yazdığım Nesne Yönelimli (OOP) "Sınav Yeri Dağıtım ve Sorgulama Sistemi" projesini canlı ortama (production) almama ve eksik kalan son komut dosyalarını tamamlamama yardım etmeni istiyorum.

Mevcut Proje Yapısı:

users.rb: Öğrenci, Öğretmen ve Asistan sınıflarını User ana sınıfından kalıtım (inheritance) yoluyla türeten dosya.
studentdirectory.rb: Öğrenci verilerini (Whole-Students.csv) belleğe alan sistem.
examlocator.rb: AssignedLists klasöründeki sınav dağıtım CSV'lerini (örn: assigned_Ayrik-Matematik.csv) tarayıp öğrencinin sınav yerini (Ders ve Salon) eşleştiren sistem.
app.rb: Sinatra kullanarak / rotasında arama kutusu ve /sorgula rotasında sonuçları döndüren ana web sunucusu.

Görev 1: CSV Parçalama Algoritması (Ruby Script) Bana öyle bir Ruby kodu yaz ki; AssignedLists klasöründeki tüm sınav dosyalarını okusun. İçindeki öğrencileri salon sütununa (Örn: Z02, Z05) göre gruplasın. Her salon için assigned_DersAdi_SalonAdi.csv adında yeni dosyalar oluştursun. En önemlisi, orijinal dosyada sıra numarası kaç olursa olsun, böldüğü her yeni sınıf dosyasında öğrencilerin sira (sıra numarası) değerini 1'den başlatarak tekrar numaralandırsın.

Görev 2: Canlı Ortam (Production) Hazırlığı Sinatra uygulamamı WEBrick yerine Puma motoruyla, çoklu iş parçacığı (multi-threading) destekleyecek şekilde 9292 portunda ayağa kaldırmak istiyorum. Bunun için bana şu iki dosyanın üretim standartlarına uygun tam kodlarını ver:

Gemfile
config.ru

Görev 3: Nginx Reverse Proxy Yapılandırması Proje, üniversitemize ait bir alan adında (domain) çalışacak. Kullanıcılar [http://sinav.domain.edu.tr](http://sinav.domain.edu.tr) adresine girdiğinde, Nginx'in bu HTTP trafiğini alıp arka planda (localhost:9292) çalışan Puma sunucuma yönlendirmesini istiyorum. Bunun için Ubuntu/Debian sunucusundaki /etc/nginx/sites-available/ içine yazmam gereken server { ... } bloğunun tam ve hatasız halini yaz.

dikkat edilmesi gereken noktalar

Veri Güncelleme Çakışması (File Locking) Sistem canlıda çalışırken kendi Linux Mint ortamından yeni oluşturduğun .csv dosyalarını sunucuya atıp üzerine yazdırmak istediğinde, Puma o milisaniyede o dosyayı okuyor olabilir. Bu çakışmayı önlemek için, yeni dosyaları atarken Sinatra'nın belleğindeki eski listeleri güvenli bir şekilde yenileyecek küçük bir "reload" (yenileme) rotası (örn: /admin/refresh_data) eklemek hayat kurtarır.

Hata Kayıtları (Loglama) Uygulama çökerse veya bir öğrencinin girdiği özel bir karakter sistemi bozarsa, hatanın ne olduğunu görmek istersin. Nginx kendi loglarını tutar ancak Sinatra tarafında app.rb içine enable :logging ekleyerek arka plandaki arama hatalarını bir metin dosyasına yazdırmak, ilerideki müdahale hızını inanılmaz artırır.

Trafik Sınırlandırması (Rate Limiting) Arama kutusuna saniyede onlarca kez tıklayan sabırsız kullanıcılar veya basit botlar sistemi yorabilir. Nginx konfigürasyonuna eklenecek tek satırlık bir limit_req kuralı ile aynı IP adresinden gelen aşırı seri istekleri engelleyebilirsin.