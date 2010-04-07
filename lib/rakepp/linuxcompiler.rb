class LinuxCompiler < GccCompiler

  def initialize(defines, compileflags, output_suffix='')
    super("linux#{output_suffix}", defines, compileflags)
  end

  def start_of_shared_lib_command(libName, artifact)
    return "g++ -shared"
  end

  def shared_extension()
    return 'so'
  end


  def add_lib_prefix(lib)
    if lib.forceLib
      return '-Wl,--whole-archive'
    else
      return ''
    end
  end

  def add_lib_suffix(lib)
    if lib.forceLib
      return '-Wl,--no-whole-archive'
    else
      return ''
    end
  end

  def start_of_libs()
    return ' -Wl,--start-group '
  end

  def end_of_libs()
    return ' -Wl,--end-group '
  end

end
