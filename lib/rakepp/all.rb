class All
  @@tasks = Array.new

  def self.add(task)
    @@tasks << task
  end

  def self.tasks
    return @@tasks
  end
end
