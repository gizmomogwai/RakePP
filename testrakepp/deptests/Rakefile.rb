require 'rubygems'
require 'rakepp'

compiler = OsxCompiler.new(['WHICH_SYSTEM=1'], '-Wall', 'i386', false)

l3 = SourceLib.new(compiler, '.', 'l3', Files.relative('./', 'test1.c'), [], ['.'])

Cleaner.new

task :default => All.tasks
