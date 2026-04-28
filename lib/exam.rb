require 'time'

# Tek bir sinavi temsil eder.
# exam_schedule.yml beklenen alanlar:
# course_name, date, time
class Exam
  attr_accessor :course_name, :date, :time, :notification_offset

  def initialize(course_name, date, time, notification_offset = 30)
    @course_name = course_name
    @date = date  
    @time = time  
    #BİLDİRİM KAÇ DK ÖNCE OLACAK 30 DK BURADA  SAKLANACAK
    @notification_offset = notification_offset.to_i
  end

  def exam_datetime
    Time.parse("#{@date} #{@time}")
  end

  def trigger_time
   # exam_time  eğer sadece exam time  değerini döndürmek isteseydim
   sinav_vakti = exam_datetime  #yukarıdaki metodu çağrarak sınav vaktini aldımm
   sinav_vakti - (@notification_offset * 60)
  end
end

#require_relative 'exam_schedule.yml':. Rubydde .yml dosyaları require edilmez.
#YAML dosyaları YAML.load_file ile çalışma anında okunur.  
