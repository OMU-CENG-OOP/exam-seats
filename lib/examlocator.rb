require 'csv'

class ExamLocator
  attr_reader :student_exams

  def initialize
    
    @student_exams = Hash.new { |hash, key| hash[key] = [] }
  end


  def load_assigned_lists(project_root_dir)

    target_folder = File.join(project_root_dir, 'AssignedLists')

    return unless Dir.exist?(target_folder)

    Dir.glob(File.join(target_folder, '*.csv')).each do |file_path|
      file_name = File.basename(file_path, '.csv')

      exam_name = file_name.sub('assigned', '')

      CSV.foreach(file_path, headers: true) do |row|
        no = row['student_no'].to_s.strip
        salon = row['salon'].to_s.strip

        unless no.empty?
          @student_exams[no] << { course: exam_name, room: salon }
        end
      end
    end
  end

  def find_exams(student_no)
    @student_exams[student_no.to_s.strip] || []
  end
  
end