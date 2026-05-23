require_relative 'user'

class Teacher < User
    
    attr_accessor :mail, :role

    def initialize(first_name, last_name, mail, role)
        super(first_name, last_name)
        @mail = mail
        @role = role
    end
end

