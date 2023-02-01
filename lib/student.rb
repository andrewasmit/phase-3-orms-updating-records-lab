require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id

  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
      SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?,?)
      SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    self
    end
  end
    
  def self.create(name, grade)
    new_student= Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(arr)
    student = Student.new(arr[0], arr[1], arr[2])
    student
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE NAME = ?"
    q = DB[:conn].execute(sql, name)[0]
    self.new_from_db(q)
  end

  def update
    sql = <<-SQL
      UPDATE students SET 
      name = ?,
      grade = ?
      WHERE
      id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
