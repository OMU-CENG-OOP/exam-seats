require 'yaml'
require_relative 'exam'


class ExamSchedule
  attr_reader :exams, :source_path

  def initialize(file_path = nil)
    @exams = []
    @source_path = nil

    load_from_yml(file_path) if file_path
  end

  def load_from_yml(file_path)
    @exams = []
    @source_path = file_path
    
    data=YAML.load_file(file_path) 

    rows = raw_exam_rows(data) 
    rows.each do |row|
      yeni_sinav = build_exam(row)

      @exams << yeni_sinav
    end


  end

  def due_exams(current_time)

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

    Exam.new(exam_row['course_name'], exam_row['date'], exam_row['time'], exam_row['notification_offset_minutes'])
  end

  def raw_exam_rows(yml_data) 

    yml_data['exams'] || []
  end
end
