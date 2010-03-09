require 'rubygems'
require 'rakepp'

compiler1 = OsxCompiler.new(['SYSTEM=1'], false, '1')
compiler2 = OsxCompiler.new(['SYSTEM=2'], false, '2')
compiler2 = OsxCompiler.new(['SYSTEM=3'], false, '2')

crossTools = CrossTools.new(compiler1, compiler2, compiler3)

base = 'libs/l1/'
sources = Files.relative(base, '*.cpp')
l1 = crossTools.sourceLib(base, 'l1', sources, [], ['.'])

l1 = SourceLib.new(compiler, base, 'l1', sources, [], ['.'])

base = 'libs/l2'
sources = Files.relative(base, '*.cpp')
l2 = crossTools.sourceLib(base, 'l2', sources, [l1], ['.'])

crossTools.exe('.', 'test', Files.relative('./', '*.cpp'), [l1], ['.'])

Cleaner.new

task :default => All.tasks
