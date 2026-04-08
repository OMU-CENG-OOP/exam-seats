# courses.yml dosyasindaki dersleri okuyup her dersin CSV listesini karistirir,
# ogrencileri salonlara paylastirir ve ayni dosyaya geri kaydeder.
#
# Beklenen ders CSV formati:
# student_no
# 2301001
# 2301002

require "yaml"
require "csv"


class CourseRosterShuffler
  attr_reader :courses, :room_capacities

  def initialize(room_capacities = default_room_capacities)
    @room_capacities = room_capacities
    # Temporary mock data for testing
    @courses = [
      { 'name' => 'DataStructures', 'students' => [101, 102, 103, 104, 105] }
    ]
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
    yaml_data = YAML.load_file(yml_path)
    
    # Iterate through the array under the 'courses' key
    yaml_data['courses'].each do |course_name|
      # Infer the CSV filename (e.g., "Ayrik-Matematik" -> "Ayrik-Matematik.csv")
      file_path = "#{course_name}.csv"
      students = []
      
      # Check if the CSV file actually exists before trying to read it
      if File.exist?(file_path)
        CSV.foreach(file_path, headers: true) do |row|
          # Convert the CSV row to a hash so we keep student_no, name, and surname
          students << row.to_h
        end
        
        @courses << { 'name' => course_name, 'file_path' => file_path, 'students' => students }
        puts "Loaded #{students.length} students for #{course_name}."
      else
        puts "WARNING: File #{file_path} not found! Skipping..."
      end
    end
  end

  def total_capacity
    total = 0
    @room_capacities.each do |room|
      total += room['capacity']
    end
    total
  end

  def shuffle_course(course_name)
    # 1. Find the specific course in our list
    course = @courses.find { |c| c['name'] == course_name }
    
    # 2. If we found the course, shuffle its students
    if course
      course['students'].shuffle! 
      puts "Shuffled students for #{course_name}."
    else
      puts "Course #{course_name} not found!"
    end
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

shuffler = CourseRosterShuffler.new
puts "Before shuffle: #{shuffler.courses.first['students']}"

shuffler.shuffle_course('DataStructures')

puts "After shuffle: #{shuffler.courses.first['students']}"