class ObjectFile
  attr_reader :source, :targetDir, :includes, :outFile, :privateDefines
  attr_writer :outFile
  def initialize(compiler, source, targetDir, includes, privateDefines=[])
    @source = source
    @targetDir = targetDir
    @includes = includes
    @privateDefines = privateDefines
    compiler.addTasks(self)
  end
  def depFile()
    return "#{outFile}.dependencies"
  end
end
