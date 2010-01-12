class SharedLib < SourceLib
  attr_reader :options

  def initialize(compiler, base, name, sources, libs, includes, options={}, privateDefines=[])
    super(compiler, base, name, sources, libs, includes, privateDefines)
    @options = options
  end

end
