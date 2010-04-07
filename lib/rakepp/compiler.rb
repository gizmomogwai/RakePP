class Compiler
  attr_reader :targetDir, :compileflags

  def initialize(targetDir, defines, compileflags)
    @targetDir = targetDir
    @defines = defines
    @compileflags = compileflags
  end

  def add_tasks(artifact)
    if (artifact.instance_of?(Exe)) then
      add_exe_tasks(artifact)
    elsif (artifact.instance_of?(SourceLib)) then
      add_source_lib_tasks(artifact)
    elsif (artifact.instance_of?(ObjectFile)) then
      add_object_tasks(artifact)
    elsif (artifact.instance_of?(Framework)) then
      add_framework_tasks(artifact)
    elsif (artifact.instance_of?(BinaryLib)) then
      add_binary_lib_tasks(artifact)
    elsif (artifact.instance_of?(SharedLib)) then
      add_shared_lib_tasks(artifact)
    else
      raise "unknown type " + artifact.to_s
    end
  end

end

