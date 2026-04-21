require "yaml"
require "csv"

class CourseRosterShuffler
  attr_reader :courses, :room_capacities

  def initialize(room_capacities = default_room_capacities)
    @room_capacities = room_capacities
    @courses = [] # Start empty
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

  # Loads course names from YAML, then reads their specific CSVs
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

  def shuffle_all
    @courses.each { |course| shuffle_course(course['name']) }
  end

  def shuffle_course(course_name)
    course = @courses.find { |c| c['name'] == course_name }
    if course
      course['students'].shuffle!
      puts "Shuffled: #{course_name}"
    end
  end

  def build_seat_plan(students)
    plan = []
    student_index = 0

    @room_capacities.each do |room|
      room_name = room['salon']
      capacity = room['capacity']

     # Fill this room until capacity is hit or students run out
      capacity.times do
        break if student_index >= students.length
        
        student = students[student_index]
        # Add the salon info to the student hash
        plan << student.merge({ 'salon' => room_name })
        student_index += 1
      end
    end
    plan
  end

  # Saves the new list (with room assignments) back to CSV
  def save_assigned_rows(file_path, assigned_rows)
    return if assigned_rows.empty?

    CSV.open(file_path, "wb") do |csv|
      # Extract headers from the first hash keys
      csv << assigned_rows.first.keys
      assigned_rows.each do |row|
        csv << row.values
      end
    end
    puts "Saved results to #{file_path}"
  end

  # Main execution method to run the whole pipeline
  def process_all_courses
    @courses.each do |course|
      # 1. Shuffle
      shuffle_course(course['name'])
      
      # 2. Build Plan
      assigned = build_seat_plan(course['students'])
      
      # 3. Save (using a new name or overwriting)
      save_assigned_rows("Lists/#{course['name']}_assigned.csv", assigned)
    end
  end
end

# --- TESTING BLOCK ---
# This block ONLY runs if you execute this specific file directly.
# It gets completely ignored if main.rb "requires" this file later.
if __FILE__ == $0
  puts "Running tests directly from courserostershuffler.rb..."

  shuffler = CourseRosterShuffler.new
  
  # Notice the paths are written assuming you are running the command 
  # from your main 'exam-seats' folder!
  shuffler.load_courses('YAMLs/courses.yml')
  shuffler.process_all_courses

  puts "Shuffling complete! Go check the Lists folder to see the assigned CSVs."
end