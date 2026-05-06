require "yaml"
require "csv"

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
    yaml_data = YAML.load_file(yml_path)
    
    yaml_data['courses'].each do |course_name|
      file_path = "Lists/#{course_name}.csv"
      students = []
      
      if File.exist?(file_path)
        CSV.foreach(file_path, headers: true) do |row|
          students << row.to_h
        end
        @courses << { 'name' => course_name, 'file_path' => file_path, 'students' => students }
      else
        puts "WARNING: #{file_path} not found."
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
    course = @courses.find { |c| c['name'] == course_name }
    if course
      course['students'].shuffle!
      puts "Shuffled: #{course_name}"
    end
  end

  def shuffle_all
    @courses.each { |course| shuffle_course(course['name']) }
  end

  #EVERYTHING BELOW THIS LINE IS PRIVATE
  private

  def build_seat_plan(student_nos)
    assigned_rows = []
    student_index = 0

    @room_capacities.each do |room|
      room_name = room['salon']
      capacity = room['capacity']

      capacity.times do
        break if student_index >= student_nos.length
        
        student = student_nos[student_index]
        assigned_rows << student.merge({ 'salon' => room_name })
        student_index += 1
      end
    end
    
    assigned_rows
  end

  def save_assigned_rows(file_path, assigned_rows)
    return if assigned_rows.empty?

    CSV.open(file_path, "wb") do |csv|
      csv << assigned_rows.first.keys
      assigned_rows.each do |row|
        csv << row.values
      end
    end
    puts "Saved results to #{file_path}"
  end
end