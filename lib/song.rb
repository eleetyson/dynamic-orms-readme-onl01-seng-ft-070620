require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

# takes the name of the class, turns it into a string, downcases, and pluralizes it
# #pluralize method uses the active_support/inflector library (above)
  def self.table_name
    self.to_s.downcase.pluralize
  end

# queries a table for the names of its columns
 # return value will be an array of the table's column names: ["id", "name", "album"]
  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')" # returns an array of hashes, ea hash has info about 1 column

    table_info = DB[:conn].execute(sql)
    column_names = [] # only info we need from each hash is the column name
    table_info.each do |row| # iterate over the array of hashes and...
      column_names << row["name"] # shovel the value for the "name" key into column_names array
    end
    column_names.compact # remove any nil values
  end

# use metaprogramming to set an attr_accessor for each column name
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym # attr_accessors need to be symbols
  end

# #initialize will take in a hash of keyword arguments
# each property will need a corresponding attr_accessor for this to work
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

# synthesizes the methods we have to dynamically craft a SQL statement to save a record
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

# to access a class method, self.table_name, inside of an instance method...
# and get the class' corresponding table name
  def table_name_for_insert
    self.class.table_name
  end

# iterate over the column names (return value of .column_names)...
# and use #send with each column name to invoke that method and capture its return value
#   push the return value of invoking a method via #send, unless that value is nil (like for id before a record is saved)
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

# dynamic way to craft our INSERT statement
# should return the table column names, without id, kind of like this: "name, album"
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

# selecting records in a dynamic manner
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
