require 'rubygems'
require 'rake/gempackagetask'

desc "Default Task"
task :default => :package

PKG_VERSION = '0.1.0'
PKG_FILES = FileList[
    'lib/**/*.rb',
    '*.xml',
    'Rakefile'
#    'test/**/*.rb',
#    'doc/**/*'
  ]

spec = Gem::Specification.new do |s|
  s.name = 'rakepp'
  s.version = PKG_VERSION
  s.summary = "Cpp Support for Rake."
  s.description = <<-EOF
    Some more high level building blocks for cpp projects.
  EOF
  s.files = PKG_FILES.to_a
  s.require_path = 'lib'
  #  s.has_rdoc = true
  s.author = "Christian Koestlin"
  s.email = 'gizmoATflopcodeDOTcom'
  s.homepage = 'http://www.flopcode.com'
  s.rubyforge_project = 'rakepp'
  s.add_dependency('progressbar', '>=0.0.3')
end

Rake::GemPackageTask.new(spec) do |pkg|
#  pkg.need_tar = true
 # pkg.need_zip = true
end
