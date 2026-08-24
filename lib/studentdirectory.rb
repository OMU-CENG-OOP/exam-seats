require 'csv'

# Tum bolum ogrencilerini bellekte tutar.
# Beklenen students.csv alani:
# student_no,name,surname,email
class StudentDirectory
  attr_reader :students_map

  def initialize
    @students_map = {}
  end

  def load_from_csv(file_path)
    CSV.foreach(file_path, headers: true) do |row|
      no = row['student_no'].to_s.strip

      unless no.empty?
        @students_map[no] = Student.new(
          no,
          row['name'].to_s.strip,
          row['surname'].to_s.strip,
          row['email'].to_s.strip
        )
      end  
    end
  end

  def find(student_no)
    @students_map[student_no.to_s.strip]
  end
end