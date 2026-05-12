require 'minitest/autorun'
require 'time'
require_relative './lib/examtriggerrunner'

# Duck typing??
# methodun inputu için gerekli mock nesnelerini oluşturuyoruz
class MockSchedule
  attr_accessor :exams
  def due_exams(time)
     @exams
  end
end

class MockNotifier
  attr_reader :notified_exams
  def initialize; @notified_exams = []; end
  def notify(exam); @notified_exams << exam; end
end


class ExamTriggerRunnerTest < Minitest::Test
  def setup
    @schedule = MockSchedule.new
    @notifier = MockNotifier.new
    @runner = ExamTriggerRunner.new(@schedule, @notifier)
    
    # Testleri sabitlemek için "şu an" zamanı: 12:00
    @current_time = Time.parse("2026-05-12 12:00:00")
  end

  def test_tam_30_dakika_kala_bildirim_gonderir
    # Sınav 12:30'da (30 dk sonra) -> Bildirim GİTMELİ
    exam = create_mock_exam("Matematik", "2026-05-12", "12:30", 1)
    @schedule.exams = [exam]

    @runner.run(@current_time)

    assert_equal 1, @notifier.notified_exams.count
    assert_equal "Matematik", @notifier.notified_exams.first.name
  end

  def test_vakti_gelmemis_sinavi_tetiklemez
    # Sınav 13:00'da -> Bildirim GİTMEMELİ
    exam = create_mock_exam("Fizik", "2026-05-12", "13:00", 2)
    @schedule.exams = [exam]

    @runner.run(@current_time)

    assert_empty @notifier.notified_exams
  end

  def test_ayni_sinavi_mukerrer_bildirmez
    # Sınav 12:15'te (15 dk kalmış, pencere içinde)
    exam = create_mock_exam("Kimya", "2026-05-12", "12:15", 3)
    @schedule.exams = [exam]

    @runner.run(@current_time) # İlk çağrı
    @runner.run(@current_time) # İkinci çağrı

    assert_equal 1, @notifier.notified_exams.count, "Aynı sınav sadece bir kez bildirilmelidir."
  end

  def test_baslamis_sinavi_bildirmez
    # Sınav 11:30'da (Çoktan başladı) -> Bildirim GİTMEMELİ
    exam = create_mock_exam("Tarih", "2026-05-12", "11:30", 4)
    @schedule.exams = [exam]

    @runner.run(@current_time)

    assert_empty @notifier.notified_exams
  end

  private

  
  def create_mock_exam(name, date, time, id)
    Struct.new(:name, :date, :time, :object_id).new(name, date, time, id)
  end
end