class OS
  def self.windows?
    return (RUBY_PLATFORM =~ /win32/i) != nil
  end
  def self.osx?
    return RUBY_PLATFORM.index('darwin') != nil
  end
  def self.linux?
    return RUBY_PLATFORM.index('linux') != nil
  end
end
