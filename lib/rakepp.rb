require 'rakepp/os'
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
require 'rakepp/crosstools'

def dir(d)
  file_create d do |t|
    mkdir_p t.name if ! File.exist?(t.name)
  end
end
