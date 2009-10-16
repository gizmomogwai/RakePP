class SourceFile
  attr_reader :fullPath, :fileName
  def initialize(fullPath, fileName)
    @fullPath = fullPath
    @fileName = fileName
  end

  def to_o
    return fileName.sub(/\.[^.]+$/, '.o')
  end

  def to_s
    return "SourceFile #{fullPath}"
  end

end
