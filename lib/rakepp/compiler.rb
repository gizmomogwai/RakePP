class Compiler
  attr_reader :targetDir
  def initialize(targetDir, defines)
    @targetDir = targetDir
    @defines = defines
  end
  def addTasks(artifact)
    if (artifact.instance_of?(Exe)) then
      addExeTasks(artifact)
    elsif (artifact.instance_of?(SourceLib)) then
      addSourceLibTasks(artifact)
    elsif (artifact.instance_of?(ObjectFile)) then
      addObjectTasks(artifact)
    elsif (artifact.instance_of?(Framework)) then
      addFrameworkTasks(artifact)
    elsif (artifact.instance_of?(BinaryLib)) then
      addBinaryLibTasks(artifact)
    elsif (artifact.instance_of?(SharedLib)) then
      addSharedLibTasks(artifact)
    else
      raise "unknown type " + artifact.to_s
    end
  end
end
