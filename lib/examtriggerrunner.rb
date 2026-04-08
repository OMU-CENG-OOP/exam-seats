require 'NotificationService'
require 'yaml'

# Zamani gelen sinavlar icin bildirim akisini calistirir.
class ExamTriggerRunner
  def initialize(exam_schedule, notification_service)
    @exam_schedule = exam_schedule
    @notification_service = notification_service
  end

  file_path = File.expand_path('../exam-seats/YAMLs/exam_schedule.yml', __dir__)
    if File.exist?(file_path)
      exam_data = YAML.load_file(file_path)
    else
      abort "Hata: Sınav dosyası bulunamadı! Aranan konum: #{file_path}"
    end
    
      def run(current_time)


  end
end
