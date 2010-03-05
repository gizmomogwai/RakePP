class LinuxCompiler < GccCompiler

  def initialize(defines, output_suffix='')
    super("linux#{output_suffix}", defines)
  end

  def startOfSharedLibCommand(libName, artifact)
    return "g++ -shared"
  end

  def sharedExtension
    return 'so'
  end
end
