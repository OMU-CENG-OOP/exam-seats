require_relative 'examschedule.rb'
require 'time'

# Tek bir sinavi temsil eder.
# exam_schedule.yml beklenen alanlar:
# course_name, date, time
class Exam
  attr_accessor :course_name, :date, :time

  def initialize(course_name, date, time)
    @course_name= course_name
    @date =date
    @time = Time.parse(time_string) # string gelen bir şeyi Time nesnesine dönüştüreceğiim
  end

  def exam_datetime # bu fonk zamanı üretecek ve hesaplayacak
    
    
    time_now=Time.now
   

  end

  def trigger_time        #tetiklenme zamanımız bir zamanı alacak ve ozamana kadar bekleyip zamanı gelince bir mesaj döndürecek
     # yeni zaman üretmeyeceğim var olan zamanı kullancam
     exam.time 

    while Time.now <  @time  # şuanki zaman < gelecek zaman eğer gelmediyese  sleep ile bekliyoruz ama 5sn de bir kontrol yapıyoruz
 
      sleep(5) # programı 5 sm de bir sürekli durdurur

      time_now =Time.new
      time_now=
    end

  end
end

# karışanlar
#@time  # instance variable  nesye ait özel değişken
#time   # method çağrısı  / yerel değişkenimiz / parametre
#Time   # Ruby class ım


exam = Exam.new("Math", "2026-04-08", "10:00") 

