class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(hash={})
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    sql1 = <<-SQL
    SELECT last_insert_rowid() FROM dogs;
    SQL

    @id = DB[:conn].execute(sql1)[0][0]
    self
  end

# review/question
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?;
    SQL

    result = DB[:conn].execute(sql, id)[0]
    dog = Dog.new(id: result[0], name: result[1], breed: result[2])
  end

#revie this
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?;
    SQL

    result = DB[:conn].execute(sql, name, breed)

    if !result.empty?
      result_data = result[0]
      dog = self.new(id: result_data[0],name: result_data[1], breed: result_data[2])
    else
      dog = self.create(name: name, breed: breed)
      dog
    end
  end

  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?;
    SQL

    dog_data = DB[:conn].execute(sql, name)[0]
    dog = self.new(id:dog_data[0], name:dog_data[1], breed: dog_data[2])
    dog
    # binding.pry
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
    # binding.pry
  end

end
