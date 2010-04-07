class GccWin32Compiler < GccCompiler
  def initialize(defines)
    super('w32', defines)
  end

  def start_of_shared_lib_command(libName)
    return "g++ -shared -Wl,--out-implib=#{libName}.a"
  end

  def shared_extension()
    return 'dll'
  end

  def add_lib(task, lib)
    if (lib.instance_of?(BinaryLib)) then
      return " -l#{lib.name}"
    elsif (lib.instance_of?(SourceLib)) then
      return " -L#{targetDir}/libs -l#{lib.name}"
    elsif (lib.instance_of?(SharedLib)) then
      return " #{targetDir}/libs/#{lib.name}.#{shared_extension()}.a"
    else
      raise "#{lib} not supported"
    end
  end
end
