require 'rubygems'
require 'progressbar'
require 'yaml'

class GccCompiler < Compiler
  def addObjectTasks(artifact)
    outName = File.join(artifact.targetDir, artifact.source.to_o)
    artifact.outFile = outName
    depFile = artifact.depFile

    depFileTask = file depFile => artifact.source.fullPath do | task |
      calcDependencies(artifact, depFile)
    end

    recreateDepFileTask = task "#{depFile}.recreate" do | task |
      if (!File.exists?(depFile))
        calcDependencies(artifact, depFile)
      end
      deps = YAML.load_file(depFile)
      missing = deps.inject(false) do |memo, d|
        memo || !File.exists?(d)
      end
      if (missing)
        calcDependencies(artifact, depFile)
        deps = YAML.load_file(depFile)
      end
      depFileTask.enhance(deps)
    end

    outFile = file outName => ["#{depFile}.recreate", depFile] do | task |
      command = "#{compiler(artifact)} -c #{defines(artifact)} #{includes(artifact)} -o #{outName} #{artifact.source.fullPath}"
      sh command
    end

    applyTask = task "#{outFile}.apply" => recreateDepFileTask do |task|
      deps = YAML.load_file(depFile)
      if (deps)
        outFile.enhance(deps)
      end
    end

    outFile.enhance([applyTask])

    directory artifact.targetDir
    directory File.dirname(outName)

    dirs = [artifact.targetDir, File.dirname(outName)]
    outFile.enhance(dirs)
    depFileTask.enhance(dirs)
    recreateDepFileTask.enhance(dirs)

    All.addObject(artifact)
    All.addDepFile(depFile)
  end

  def compiler(artifact)
    if ((artifact.source.fullPath.index(".cpp") != nil) ||
        (artifact.source.fullPath.index(".cxx") != nil)) then
      return "g++ #{compileflags}"
    else
      return "gcc #{compileflags}"
    end
  end

  def defines(artifact)
    res = ""
    allDefines = @defines + artifact.privateDefines
    allDefines.each do |define|
      res << "-D#{define} "
    end
    return res
  end

  def includes(artifact)
    res = ""
    artifact.includes.each do |aInclude|
      res << "-I#{aInclude} "
    end
    return res
  end

  def calcDependencies(artifact, taskToEnhance)
    source = artifact.source
    command = "#{compiler(artifact)} -M #{defines(artifact)} #{includes(artifact)} #{source.fullPath}"
    deps = `#{command}`
    if deps.length == 0
      raise 'cannot calc dependencies'
    end
    deps = deps.gsub(/\\\n/,'').split()[1..-1]
    File.open(artifact.depFile, 'wb') do |f|
      f.write(deps.to_yaml)
    end
  end

  def startOfSourceLibCommand(outName, artifact)
    return "ar -r #{outName}"
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
      command = startOfSourceLibCommand(outName, artifact)
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
    command = startOfSharedLibCommand(outName, artifact)
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
    command = "g++ #{compileflags} -o #{artifact.outFile}"
    objects.each do |o|
      command += " #{o}"
    end

    command += startOfLibs
    LibHelper.tr_libs(artifact.libs).each do |lib|
      command += addLib(task, lib)
    end
    command += endOfLibs

    sh command
    doAdditionalWorkForExe(artifact)
  end

  addTransitiveLibraryPrerequisites(theTask, artifact)

  file artifact.outFile => [exesName]
  All.add(artifact.outFile)
  directory exesName
end
  def startOfLibs
    return ''
  end
  def endOfLibs
    return ''
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
      return "#{addLibPrefix(lib)} -L#{targetDir}/libs -l#{lib.name} #{addLibSuffix(lib)}"
    elsif (lib.instance_of?(SharedLib)) then
      return " #{targetDir}/libs/#{lib.name}.so "
    else
      raise "#{lib} not supported"
    end
  end

  def addLibPrefix(lib)
    return ''
  end

  def addLibSuffix(lib)
    return ''
  end

end
