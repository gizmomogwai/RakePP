require 'rubygems'
require 'progressbar'
require 'yaml'

class GccCompiler < Compiler
  def add_object_tasks(artifact)
    outName = File.join(artifact.targetDir, artifact.source.to_o)
    outDir = File.dirname(outName)

    artifact.outFile = outName
    depFile = artifact.dep_file

    depFileTask = file depFile => artifact.source.fullPath { | task | calc_dependencies(artifact, depFile) }
    recreateDepFileTask = recreate_task(depFile, artifact, depFileTask)

    outFile = file outName => ["#{outName}.apply"] do | task |
      sh "#{compiler(artifact)} -c #{defines(artifact)} #{includes(artifact)} -o #{outName} #{artifact.source.fullPath}"
    end

    applyTask = apply_task(outFile, recreateDepFileTask, depFile)
    outFile.enhance([applyTask])
    dirs = [artifact.targetDir, outDir]
    dirs.each { |d| directory d }
    [outFile, depFileTask, recreateDepFileTask].each { |task| task.enhance(dirs) }
    All.addObject(artifact)
    All.addDepFile(depFile)
  end

  def apply_task(outFile, recreateDepFileTask, depFile)
    task "#{outFile}.apply" => recreateDepFileTask do |task|
      deps = YAML.load_file(depFile)
      if (deps)
        outFile.enhance(deps)
      end
      outFile.enhance([depFile])
    end
  end

  def recreate_task(depFile, artifact, depFileTask)
    task "#{depFile}.recreate" do | task |
      if (!File.exists?(depFile))
        calc_dependencies(artifact, depFile)
      end
      deps = YAML.load_file(depFile)
      if (dep_missing?(deps))
        calc_dependencies(artifact, depFile)
        deps = YAML.load_file(depFile)
      end
      depFileTask.enhance(deps)
    end
  end

  def dep_missing?(deps)
    deps.inject(false) do |memo, d|
      memo || !File.exists?(d)
    end
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

  def calc_dependencies(artifact, taskToEnhance)
    source = artifact.source
    command = "#{compiler(artifact)} -M #{defines(artifact)} #{includes(artifact)} #{source.fullPath}"
    deps = `#{command}`
    if deps.length == 0
      raise 'cannot calc dependencies'
    end
    deps = deps.gsub(/\\\n/,'').split()[1..-1]
    File.open(artifact.dep_file, 'wb') do |f|
      f.write(deps.to_yaml)
    end
  end

  def start_of_source_lib_command(outName, artifact)
    return "ar -r #{outName}"
  end

  def add_source_lib_tasks(artifact)
    outDir = File.join(@targetDir, artifact.name)

    objects = artifact.sources.map { |source| ObjectFile.new(self, source, outDir, artifact.tr_includes, artifact.privateDefines).outFile }

    libsName = File.join(@targetDir, 'libs')
    outName = File.join(libsName, "lib#{artifact.name}.a")

    artifact.outFile = outName
    desc "Create SourceLib #{outName}"
    theTask = file outName => objects do | task |
      sh objects.inject(start_of_source_lib_command(outName, artifact)) { | command, o | "#{command} #{o}" }
    end

    add_transitive_library_prerequisites(theTask, artifact)

    file outName => [libsName]
    All.add(outName)
    directory libsName
  end

  def add_shared_lib_tasks(artifact)
    outDir = File.join(@targetDir, artifact.name)
    objects = artifact.sources.map { |source| ObjectFile.new(self, source, outDir, artifact.tr_includes, artifact.privateDefines).outFile }

    libsName = File.join(@targetDir, 'libs')
    outName = File.join(libsName, "#{artifact.name}.#{shared_extension()}")
    artifact.outFile = outName
    desc "Create SharedLib #{outName}"
    theTask = file outName => objects do | task |
      command = start_of_shared_lib_command(outName, artifact)
      objects.each { |o| command += " #{o}" }
      LibHelper.tr_libs(artifact.libs).each { |lib| command += add_lib(task, lib) }
      command += " -o #{outName}"
      sh command
    end

    add_transitive_library_prerequisites(theTask, artifact)

    file outName => [libsName]
    All.add(outName)
    directory libsName
  end

  def add_binary_lib_tasks(artifact)
    artifact.outFile = "lib#{artifact.name}.a"
  end

  def add_framework_tasks(artifact)
    artifact.outFile = artifact.name
  end

  def add_exe_tasks(artifact)
    outDir = File.join(@targetDir, artifact.name)
    objects = artifact.sources.map { |source| ObjectFile.new(self, source, outDir, artifact.tr_includes).outFile }
    exesName = File.join(@targetDir, 'exes')
    artifact.outFile = File.join(exesName, artifact.name + '.exe')
    desc "Create Exe #{artifact.outFile}"
    theTask = file artifact.outFile => objects do | task |
      command = "g++ #{compileflags} -o #{artifact.outFile}"
      objects.each { |o| command += " #{o}" }
      command += start_of_libs()
      LibHelper.tr_libs(artifact.libs).each { |lib| command += add_lib(task, lib) }
      command += end_of_libs()
      sh command
      do_additional_work_for_exe(artifact)
    end

    add_transitive_library_prerequisites(theTask, artifact)

    file artifact.outFile => [exesName]
    All.add(artifact.outFile)
    directory exesName
  end

  def start_of_libs()
    return ''
  end
  def end_of_libs()
    return ''
  end
  def do_additional_work_for_exe(artifact)
  end

  def add_transitive_library_prerequisites(theTask, artifact)
    LibHelper.tr_libs(artifact.libs).each do |lib|
      theTask.prerequisites << lib.outFile unless lib.kind_of?(BinaryLib)
    end
  end

  def add_lib(task, lib)
    if (lib.instance_of?(BinaryLib)) then
      return " -L#{lib.path||'/usr/lib'} -l#{lib.name} "
    elsif (lib.instance_of?(SourceLib)) then
      return "#{add_lib_prefix(lib)} -L#{targetDir}/libs -l#{lib.name} #{add_lib_suffix(lib)}"
    elsif (lib.instance_of?(SharedLib)) then
      return " #{targetDir}/libs/#{lib.name}.so "
    else
      raise "#{lib} not supported"
    end
  end

  def add_lib_prefix(lib)
    return ''
  end

  def add_lib_suffix(lib)
    return ''
  end

end
