class LinuxCompiler < GccCompiler

  def initialize(defines, compileflags, output_suffix='')
    super("linux#{output_suffix}", defines, compileflags)
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

  def startOfLibs
    return ' -Wl,--start-group '
  end

  def endOfLibs
    return ' -Wl,--end-group '
  end

end
