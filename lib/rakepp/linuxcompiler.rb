class LinuxCompiler < GccCompiler
  def initialize(defines)
    super('linux', defines)
  end
  def startOfSharedLibCommand(libName)
    return "g++ -shared"
  end
  def sharedExtension
    return 'so'
  end
end
