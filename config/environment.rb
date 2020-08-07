require 'sqlite3'


DB = {:conn => SQLite3::Database.new("db/songs.db")} # create the database and connection
DB[:conn].execute("DROP TABLE IF EXISTS songs") # drop the songs table if it exists already

# create a songs table
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true
# queries will be returned as hashes (line 19), instead of nested arrays (line 20)
# {"id"=>1, "name"=>"Hello", "album"=>"25", 0 => 1, 1 => "Hello", 2 => "25"}
# [[1, "Hello", "25"]]
