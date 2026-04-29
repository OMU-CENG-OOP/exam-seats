require 'yaml'
require_relative 'exam'

# exam_schedule.yml dosyasini okuyup sinav nesneleri uretir.
class ExamSchedule
  attr_reader :exams, :source_path

  def initialize(file_path = nil)
    @exams = []
    @source_path = nil

    load_from_yml(file_path) if file_path
  end

  def load_from_yml(file_path)
    @source_path = file_path
    data=YAML.load_file(file_path) 

    rows = raw_exam_rows(data) 
    rows.each do |row|
      yeni_sinav = build_exam(row)

      @exams << yeni_sinav
    end

    # TODO: YAML dosyasini okuyup Exam nesneleri uret.
    # Beklenen akisin iskeleti:
    # 1. Dosyayi oku
    # 2. Sinav satirlarini parse et
    # 3. Her kayittan bir Exam nesnesi olustur
    # 4. @exams dizisine ata
    #raise NotImplementedError, "#{self.class}#load_from_yml ogrenci tarafindan doldurulacak."
  end

  def due_exams(current_time)
    #
    # Runner bu metodu cagirir.
    # Bu metod, verilen anda bildirimi tetiklenmesi gereken Exam nesnelerini donmelidir.
    # raise NotImplementedError, "#{self.class}#due_exams ogrenci tarafindan doldurulacak."
    @exams.select do |exam|
      exam.trigger_time <= current_time
    end 
  end

  def add_exam(exam)
    @exams << exam
  end

  def reload!
    raise ArgumentError, 'Yeniden yuklemek icin source_path bilinmelidir.' unless source_path

    load_from_yml(source_path)
  end

  def empty?  
    exams.empty?
  end

  private

  def build_exam(exam_row)
    # TODO: exam_row icinden gerekli alanlari alip Exam.new(...) cagir.
    #raise NotImplementedError, "#{self.class}#build_exam ogrenci tarafindan doldurulacak."
    Exam.new(exam_row['course_name'], exam_row['date'], exam_row['time'], exam_row['notification_offset_minutes'])
  end

  def raw_exam_rows(yml_data) # veriyi ayıklama
    # TODO: YAML yapisindan sinav satirlarini cikart.
    #raise NotImplementedError, "#{self.class}#raw_exam_rows ogrenci tarafindan doldurulacak."
    yml_data['exams'] || [] 
end
