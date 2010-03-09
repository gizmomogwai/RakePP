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


  def addLibPrefix(lib)
    if lib.forceLib
      return '-Wl,--whole-archive'
    else
      return ''
    end
  end

  def addLibSuffix(lib)
    if lib.forceLib
      return '-Wl,--no-whole-archive'
    else
      return ''
    end
  end

end
