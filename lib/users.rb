class User
  attr_accessor :no, :name, :surname, :email

  def initialize(no,name, surname, email)
    @no = no
    @name = name 
    @surname = surname
    @email = email
  end

  def full_name
    "#{@name} #{@surname}"
  end
end

class Student < User
  
end

class Teacher < User

end

class Assistant < User
  
end