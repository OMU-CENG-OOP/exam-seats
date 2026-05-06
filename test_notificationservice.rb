require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'

require_relative 'lib/notificationservice'

class TestNotificationService < Minitest::Test
  ExamStub = Struct.new(:course_name, :date, :time)

  class StudentDirectoryStub
    def initialize(students = {})
      @students = students
    end

    def find(student_no)
      @students[student_no]
    end
  end

  def test_console_notification_prints_messages_without_external_service
    Dir.mktmpdir do |tmpdir|
      lists_path = File.join(tmpdir, 'Lists')
      FileUtils.mkdir_p(lists_path)
      File.write(
        File.join(lists_path, 'TestCourse.csv'),
        <<~CSV
          student_no,name,surname,email
          2301001,Ali,Veli,ali@example.com
          2301002,Ayse,Kaya,ayse@example.com
        CSV
      )

      student_directory = StudentDirectoryStub.new(
        '2301001' => { 'name' => 'Ali', 'surname' => 'Veli' },
        '2301002' => { 'name' => 'Ayse', 'surname' => 'Kaya' }
      )
      service = ConsoleNotificationService.new(student_directory, lists_path: lists_path)
      exam = ExamStub.new('TestCourse', '2026-05-10', '09:00')

      output, _error = capture_io do
        notifications = service.notify(exam)

        assert_equal 2, notifications.length
        assert_equal 'console', notifications.first[:channel]
      end

      assert_includes output, '[CONSOLE]'
      assert_includes output, 'Ogrenci: Ali Veli'
      assert_includes output, 'Ogrenci: Ayse Kaya'
      assert_includes output, 'Ders: TestCourse'
      assert_includes output, 'Tarih: 2026-05-10'
      assert_includes output, 'Saat: 09:00'
    end
  end
end
