require 'rubygems'
require 'rakepp'

compiler = OsxCompiler.new(['WHICH_SYSTEM=1'], '-Wall', 'i386', false)

base = 'libs/l1/'
sources = Files.relative(base, '*.cpp')
l1 = SourceLib.new(compiler, base, 'l1', sources, [], ['.'])

base = 'libs/l2'
sources = Files.relative(base, '*.cpp')
l2 = SourceLib.new(compiler, base, 'l2', sources, [l1], ['.'])

l3 = SourceLib.new(compiler, '.', 'l3', Files.relative('./', 'test.c'), [], ['.'])

Exe.new(compiler, '.', 'test', Files.relative('./', 'main1.cpp'), [l2], ['.'])

Cleaner.new


task :default => All.tasks
