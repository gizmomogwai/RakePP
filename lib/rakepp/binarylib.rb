class BinaryLib
  attr_reader :name, :includes, :outFile, :libs, :path
  attr_writer :outFile

  def initialize(compiler, name, libs=[], includes=[], path=nil)
    @name = name
    @libs = libs
    @includes = includes
    @path = path
    compiler.addTasks(self)
  end

end
