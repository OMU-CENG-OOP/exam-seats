require 'minitest/autorun'

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
end