require 'sinatra'
require_relative '../lib/users'             
require_relative '../lib/studentdirectory'
require_relative '../lib/examlocator'

# 1. Öğrenci Rehberini Yükle
set :directory, StudentDirectory.new
students_path = File.expand_path('../Lists/Whole-Students.csv', __dir__)
settings.directory.load_from_csv(students_path)

# 2. Sınav Yerlerini (Klasörü) Yükle
set :locator, ExamLocator.new
proje_ana_dizini = File.expand_path('..', __dir__) 
settings.locator.load_assigned_lists(proje_ana_dizini)
get '/' do
  erb :index
end

post '/sorgula' do
  student_no = params[:student_no]
  
  @ogrenci = settings.directory.find(student_no)
  @sinavlar = settings.locator.find_exams(student_no)

  if @ogrenci
    
  
    erb :sonuc
  else
    "Hata: Bu numaraya ait bir öğrenci bulunamadı. Lütfen tekrar deneyin."
  end
end