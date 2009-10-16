class GccCompiler < Compiler
  def addObjectTasks(artifact)
    outName = File.join(artifact.targetDir, artifact.source.to_o)
    artifact.outFile = outName
    file outName => artifact.source.fullPath do |task|
      theDefines = ""
      allDefines = @defines + artifact.privateDefines
      allDefines.each do |define|
        theDefines << "-D#{define} "
      end

      theIncludes = ""
      artifact.includes.each do |aInclude|
        theIncludes << "-I#{aInclude} "
      end
      if ((artifact.source.fullPath.index(".cpp") != nil) ||
          (artifact.source.fullPath.index(".cxx") != nil)) then
        compiler = "g++ #{ARCH} #{OPTIMIZE} -fno-common -Wall -exceptions"
      else
        compiler = "gcc #{ARCH} #{OPTIMIZE} -fno-common -Wall"
      end

      command = "#{compiler} -c #{theDefines} #{theIncludes} -o #{outName} #{artifact.source.fullPath}"
      sh command
    end
    directory artifact.targetDir
    directory File.dirname(outName)
    help = file outName => [artifact.targetDir, File.dirname(outName)]
  end

  def addSourceLibTasks(artifact)
    outDir = File.join(@targetDir, artifact.name)

    objects = []
    artifact.sources.each do |source|
      objects << ObjectFile.new(self, source, outDir, artifact.tr_includes, artifact.privateDefines).outFile
    end

    libsName = File.join(@targetDir, 'libs')
    outName = File.join(libsName, "lib#{artifact.name}.a")

    artifact.outFile = outName
    desc "Create SourceLib #{outName}"
    theTask = file outName => objects do | task |
      command = "ar -r #{outName}"
      objects.each do | o |
        command += " #{o}"
      end
      sh command
    end

    addTransitiveLibraryPrerequisites(theTask, artifact)

    file outName => [libsName]
    All.add(outName)
    directory libsName
  end

  def addSharedLibTasks(artifact)
    outDir = File.join(@targetDir, artifact.name)
    objects = []
    artifact.sources.each do |source|
      objects << ObjectFile.new(self, source, outDir, artifact.tr_includes, artifact.privateDefines).outFile
    end
    libsName = File.join(@targetDir, 'libs')
    outName = File.join(libsName, "#{artifact.name}.#{sharedExtension}")
    artifact.outFile = outName
    desc "Create SharedLib #{outName}"
    theTask = file outName => objects do | task |
      command = startOfSharedLibCommand(outName)
      objects.each do |o|
        command += " #{o}"
      end

      LibHelper.tr_libs(artifact.libs).each do |lib|
        command += addLib(task, lib)
      end

      command += " -o #{outName}"
      sh command
    end

    addTransitiveLibraryPrerequisites(theTask, artifact)

    file outName => [libsName]
    All.add(outName)
    directory libsName
  end

  def addBinaryLibTasks(artifact)
    artifact.outFile = "lib#{artifact.name}.a"
  end

  def addFrameworkTasks(artifact)
    artifact.outFile = artifact.name
  end


  def addExeTasks(artifact)
    outDir = File.join(@targetDir, artifact.name)

    objects = []
    artifact.sources.each do |source|
      objects << ObjectFile.new(self, source, outDir, artifact.tr_includes).outFile
    end

    exesName = File.join(@targetDir, 'exes')
    artifact.outFile = File.join(exesName, artifact.name + '.exe')
    desc "Create Exe #{artifact.outFile}"
    theTask = file artifact.outFile => objects do | task |
      command = "g++ #{ARCH} -o #{artifact.outFile}"
      objects.each do |o|
        command += " #{o}"
      end

      LibHelper.tr_libs(artifact.libs).each do |lib|
        command += addLib(task, lib)
      end

      sh command
      doAdditionalWorkForExe(artifact)
    end

    addTransitiveLibraryPrerequisites(theTask, artifact)

    file artifact.outFile => [exesName]
    All.add(artifact.outFile)
    directory exesName
  end

  def doAdditionalWorkForExe(artifact)
  end

  def addTransitiveLibraryPrerequisites(theTask, artifact)
    LibHelper.tr_libs(artifact.libs).each do |lib|
      theTask.prerequisites << lib.outFile unless lib.kind_of?(BinaryLib)
    end
  end

  def addLib(task, lib)
    if (lib.instance_of?(BinaryLib)) then
      return " -L#{lib.path||'/usr/lib'} -l#{lib.name} "
    elsif (lib.instance_of?(SourceLib)) then
      return " -L#{targetDir}/libs -l#{lib.name}"
    elsif (lib.instance_of?(SharedLib)) then
      return " #{targetDir}/libs/#{lib.name}.so "
    else
      raise "#{lib} not supported"
    end
  end

end
