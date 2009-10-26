class All
  @@tasks = Array.new
  @@objects = Array.new
  @@depFiles = Array.new

  def self.add(task)
    @@tasks << task
  end

  def self.addObject(o)
    @@objects << o
  end
  def self.addDepFile(filename)
    @@depFiles << filename
  end

  def self.tasks
    return @@tasks
  end

  def self.objects
    return @@objects
  end

  def self.depFiles
    return @@depFiles
  end

end
