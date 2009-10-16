class Framework < BinaryLib
  def initialize(compiler, name, libs)
    super(compiler, name, libs, ["/System/Library/Frameworks/#{name}.framework/Versions/Current/Headers"])
  end
end
