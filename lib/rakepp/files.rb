require 'pathname'

class Files
  def self.relative(base, pattern)
    globPattern = Pathname.new(base) + pattern
    return Pathname.glob(globPattern.to_s).collect do |path|
      f = path.to_s
      SourceFile.new(f, f.sub(base, ''))
    end
  end
end
