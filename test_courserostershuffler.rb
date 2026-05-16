require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'

require_relative 'lib/courserostershuffler'

class TestCourseRosterShuffler < Minitest::Test

  def setup
    @shuffler = CourseRosterShuffler.new
  end

  def test_default_room_capacities_load_correctly
    rooms = @shuffler.room_capacities
    assert_equal 5, rooms.length
    assert_equal 'Z02', rooms.first['salon']
  end

  def test_total_capacity_calculation
    total = @shuffler.total_capacity
    assert_equal 264, total
  end

  def test_courses_starts_empty
    assert_empty @shuffler.courses
  end

  def test_load_courses_with_valid_files
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        FileUtils.mkdir_p('Lists')
        File.write('Lists/BIL101.csv', "ogrenci_no,isim\n123,Furkan\n456,Ahmet\n")
        File.write('test_courses.yml', "courses:\n  - BIL101\n")
        @shuffler.load_courses('test_courses.yml')

        assert_equal 1, @shuffler.courses.length
        loaded_course = @shuffler.courses.first
        assert_equal 'BIL101', loaded_course['name']
        assert_equal 'Lists/BIL101.csv', loaded_course['file_path']
        assert_equal 2, loaded_course['students'].length
        assert_equal 'Furkan', loaded_course['students'].first['isim']
      end
    end
  end

  def test_load_courses_with_missing_csv
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        File.write('test_courses_missing.yml', "courses:\n  - OlmayanDers\n")

        output, _error = capture_io do
          @shuffler.load_courses('test_courses_missing.yml')
        end

        assert_empty @shuffler.courses
        assert_match(/WARNING: Lists\/OlmayanDers.csv not found./, output)
      end
    end
  end

  def test_shuffle_course_success
    fake_students = [
      { 'ogrenci_no' => '1', 'isim' => 'Ali' },
      { 'ogrenci_no' => '2', 'isim' => 'Ayşe' },
      { 'ogrenci_no' => '3', 'isim' => 'Mehmet' }
    ]
    
    @shuffler.instance_variable_set(:@courses, [
      { 'name' => 'BIL101', 'file_path' => 'dummy.csv', 'students' => fake_students.dup }
    ])

    output, _error = capture_io do
      @shuffler.shuffle_course('BIL101')
    end

    assert_match(/Shuffled: BIL101/, output)
    shuffled_students = @shuffler.courses.first['students']
    assert_equal 3, shuffled_students.length
    
    orijinal_sorted = fake_students.sort_by { |s| s['ogrenci_no'] }
    shuffled_sirali = shuffled_students.sort_by { |s| s['ogrenci_no'] }
    assert_equal orijinal_sorted, shuffled_sirali
  end

  def test_shuffle_course_not_found
    @shuffler.instance_variable_set(:@courses, [
      { 'name' => 'BIL101', 'students' => [] }
    ])

    output, _error = capture_io do
      @shuffler.shuffle_course('OlmayanDers')
    end

    assert_empty output
  end

  def test_shuffle_all
    @shuffler.instance_variable_set(:@courses, [
      { 'name' => 'BIL101', 'students' => [1, 2, 3] },
      { 'name' => 'MAT101', 'students' => [4, 5, 6] }
    ])

    output, _error = capture_io do
      @shuffler.shuffle_all
    end

    assert_match(/Shuffled: BIL101/, output)
    assert_match(/Shuffled: MAT101/, output)
  end
end