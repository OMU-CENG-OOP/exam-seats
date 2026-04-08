require 'yaml'
require 'time'

# exam_schedule.yml dosyasini okuyup sinav nesneleri uretir.
class ExamSchedule
  attr_reader :exams

  def initialize
    @exams = []
  end

  def load_from_yml(file_path)
    data = YAML.load_file(file_path)

    data['exams'].each do |exam_data|
      new_exam = Exam.new(
        exam_data['course_name'],
        exam_data['date'],
        exam_data['time']
      )
    end

  end

  def due_exams(current_time)
    @exams.select do |exam|
      exam.trigger_time.strftime("%Y-%m-%d %H:%M") == current_time.strftime("%Y-%m-%d %H:%M")
    end

  end
end
