require 'rakepp/os'

OPTIMIZE = '-O3'
#OPTIMIZE = ''

if OS.osx?
  ARCH = '-arch i386'
else
  ARCH = ''
end


require 'rakepp/cleaner'
require 'rakepp/all'
require 'rakepp/compiler'
require 'rakepp/gcccompiler'
require 'rakepp/linuxcompiler'
require 'rakepp/osxcompiler'
require 'rakepp/gccwin32compiler'
require 'rakepp/libhelper'
require 'rakepp/sourcelib'
require 'rakepp/sharedlib'
require 'rakepp/exe'
require 'rakepp/objectfile'
require 'rakepp/sourcefile'
require 'rakepp/binarylib'
require 'rakepp/framework'
require 'rakepp/files'
