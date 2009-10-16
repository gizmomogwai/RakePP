class GccWin32Compiler < GccCompiler
  def initialize(defines)
    super('w32', defines)
  end

  def startOfSharedLibCommand(libName)
    return "g++ -shared -Wl,--out-implib=#{libName}.a"
  end

  def sharedExtension
    return 'dll'
  end

  def addLib(task, lib)
    if (lib.instance_of?(BinaryLib)) then
      return " -l#{lib.name}"
    elsif (lib.instance_of?(SourceLib)) then
      return " -L#{targetDir}/libs -l#{lib.name}"
    elsif (lib.instance_of?(SharedLib)) then
      return " #{targetDir}/libs/#{lib.name}.#{sharedExtension}.a"
    else
      raise "#{lib} not supported"
    end
  end
end
