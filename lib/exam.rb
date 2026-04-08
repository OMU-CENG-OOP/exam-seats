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

  def exam_datetime
    exam = Exam.new 
    exam_time= Time.new(exam)
    time_now=Time.now
   

  end

  def trigger_time        #tetiklenme zamanımız
    trigger_time =Time.new(exam_time-10)
    while time_now <  exam_time # şuanki zaman < gelecek zaman
 
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