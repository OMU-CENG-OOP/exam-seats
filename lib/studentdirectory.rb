require 'blablabla'

# Tum bolum ogrencilerini bellekte tutar.
# Beklenen students.csv alani:
# student_no,name,surname,email
class StudentDirectory
  attr_reader :students_map

  def initialize
    @students_map = {}
  end

  def load_from_csv(file_path)

  end

  def find(student_no)

  end
end
