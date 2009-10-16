class SourceLib
  attr_reader :name, :sources, :includes, :outFile, :libs, :privateDefines
  attr_writer :outFile, :privateDefines
  def initialize(compiler, base, name, sources, libs, includes, privateDefines=[])
    @name = name
    @sources = sources
    @libs = libs
    @includes = includes.collect do |i|
      if (i[0].chr == '/')
        i
      else
        File.join(base, i)
      end
    end
    @privateDefines = privateDefines
    compiler.addTasks(self)
  end

  def tr_includes
    res = @includes.collect
    LibHelper.tr_libs(libs).each do |lib|
      if res.index(lib) == nil then
        lib.includes.each do |i|
          res << i unless res.index(i) != nil
        end
      end
    end
    return res
  end
end
