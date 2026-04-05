# courses.yml dosyasindaki dersleri okuyup her dersin CSV listesini karistirir,
# ogrencileri salonlara paylastirir ve ayni dosyaya geri kaydeder.
#
# Beklenen ders CSV formati:
# student_no
# 2301001
# 2301002
class CourseRosterShuffler
  attr_reader :courses, :room_capacities

  def initialize(room_capacities = default_room_capacities)
    @courses = []
    @room_capacities = room_capacities
  end

  def default_room_capacities
    [
      { 'salon' => 'Z02', 'capacity' => 108 },
      { 'salon' => 'Z05', 'capacity' => 48 },
      { 'salon' => 'Z07', 'capacity' => 36 },
      { 'salon' => 'Z08', 'capacity' => 36 },
      { 'salon' => 'Z09', 'capacity' => 36 }
    ]
  end

  def load_courses(yml_path)

  end

  def total_capacity

  end

  def shuffle_course(course_name)

  end

  def shuffle_all

  end

  private

  def build_seat_plan(student_nos)

    assigned_rows
  end

  def save_assigned_rows(file_path, assigned_rows)

  end
end
