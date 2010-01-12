class OsxCompiler < GccCompiler

  def initialize(defines, gui=true)
    super('osx', defines)
    @gui = gui
  end

  def startOfSharedLibCommand(libName)
    puts libName
    return "g++ #{ARCH} -dynamiclib -install_name #{File.basename(libName)}"
  end

  def sharedExtension
    return 'so'
  end

  def addLib(task, lib)
    if (lib.instance_of?(Framework)) then
      return " -framework #{lib.name}"
    else
      return super(task, lib)
    end
  end

  def doAdditionalWorkForExe(artifact)
    if @gui
      sh "/Developer/Tools/Rez -o #{artifact.outFile} appResources.r"
    end
  end

end
