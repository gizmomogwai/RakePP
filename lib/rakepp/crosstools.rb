class CrossTools

  def initialize(compilerHash)
    @compilerHash = compilerHash
  end

  def sourceLib(compilers, base, name, sources, dependencies, includes, privateDefines=[], forceLib=false)
    todo = get_compilers(compilers)
    return todo.inject(Hash.new) do |memo, pair|
      key = pair[0]
      compiler = pair[1]
      deps = dependencies[key]
      if deps == nil
        if dependencies.size == 0
          deps = Array.new
        else
          raise "missing deps for sourcelib: '#{name}' and compiler: '#{key}'"
        end
      end
      memo[key] = [SourceLib.new(compiler, base, name, sources, deps, includes, privateDefines, forceLib)]
      memo
    end
  end

  def exe(compilers, base, name, sources, libs, includes)
    todo = get_compilers(compilers)
    return todo.inject(Hash.new) do |memo, pair|
      key = pair[0]
      compiler = pair[1]
      l = libs[key]
      if l == nil
        raise "missing libs for exe: '#{name}' and compiler: '#{key}'"
      end
      memo[key] = Exe.new(compiler, base, name, sources, l, includes)
      memo
    end
  end

  def get_compilers(compilers)
    if compilers == nil
      return @compilerHash
    else
      return compilers.inject(Hash.new) do |memo, i|
        memo[i] =  @compilerHash[i]
        memo
      end
    end
  end

end
