class ObjectFile
  attr_reader :source, :targetDir, :includes, :outFile, :privateDefines
  attr_writer :outFile
  def initialize(compiler, source, targetDir, includes, privateDefines=[])
    @source = source
    @targetDir = targetDir
    @includes = includes
    @privateDefines = privateDefines
    compiler.add_tasks(self)
  end

  def dep_file()
    return "#{outFile}.dependencies"
  end

end
