class LibHelper

  attr_reader :all_libs

  def self.tr_libs(libs)
    return LibHelper.new(libs).all_libs
  end

  private

  def add_unique(lib)
    @all_libs.delete(lib)
    @all_libs.push(lib)
  end

  def add(lib)
    add_unique(lib)
    lib.libs.each do |aLib|
      add(aLib)
    end
  end

  def initialize(libs)
    @all_libs = Array.new
    libs.each do | lib |
      add(lib)
    end
  end
end
