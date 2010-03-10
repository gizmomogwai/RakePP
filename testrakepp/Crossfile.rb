require 'rubygems'
require 'rakepp'

compiler1 = OsxCompiler.new(['WHICH_SYSTEM=1'], '', 'i386', false, '1')
compiler2 = OsxCompiler.new(['WHICH_SYSTEM=2'], '', 'i386', false, '2')
compiler3 = OsxCompiler.new(['WHICH_SYSTEM=3'], '', 'i386', false, '3')

crossTools = CrossTools.new({:HOST1 => compiler1, :HOST2 => compiler2, :HOST3 => compiler3})

base = 'libs/l1/'
sources = Files.relative(base, '*.cpp')
l1 = crossTools.sourceLib([:HOST1, :HOST3], base, 'l1', sources, {}, ['.'])

base = 'libs/l2'
sources = Files.relative(base, '*.cpp')
l2 = crossTools.sourceLib([:HOST1], base, 'l2', sources, l1, ['.'])

exe1 = crossTools.exe([:HOST1, :HOST3], '.', 'test1', Files.relative('./', 'main1.cpp'), l1, ['.'])
exe2 = crossTools.exe([:HOST1, :HOST3], '.', 'test2', Files.relative('./', 'main2.cpp'), l2, ['.'])

puts exe1[:HOST1].outFile
puts exe1[:HOST3].outFile
puts exe2[:HOST1].outFile

Cleaner.new

task :default => All.tasks
