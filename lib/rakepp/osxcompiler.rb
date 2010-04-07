class OsxCompiler < GccCompiler

  def initialize(defines, compileflags, architecture, gui=true, output_suffix='')
    super("osx#{output_suffix}", defines, "#{compileflags} -arch #{architecture}")
    @architecture = architecture
    @gui = gui
  end

  def start_of_source_lib_command(outname, artifact)
    return "libtool -static -arch_only #{@architecture} -o #{outname}"
  end

  def start_of_shared_lib_command(libName, artifact)
    name = artifact.options[:name]
    if name == nil
      name = File.basename(libName)
    end
    return "g++ -arch #{@architecture} -dynamiclib -install_name #{name}"
  end

  def shared_extension()
    return 'so'
  end

  def add_lib(task, lib)
    if (lib.instance_of?(Framework)) then
      return " -framework #{lib.name}"
    else
      return super(task, lib)
    end
  end

  def do_additional_work_for_exe(artifact)
    if @gui
      sh "/Developer/Tools/Rez -o #{artifact.outFile} appResources.r"
    end
  end

end
