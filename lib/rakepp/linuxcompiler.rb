class LinuxCompiler < GccCompiler
  def initialize(defines)
    super('linux', defines)
  end
  def startOfSharedLibCommand(libName, artifact)
    return "g++ -shared"
  end
  def sharedExtension
    return 'so'
  end
end
