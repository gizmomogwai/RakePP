class Cleaner
  def initialize()

    desc "Clean all artifacts"
    task :clean do
      Rake::Task.tasks.reverse_each do | t |
        FileUtils.rm_rf(t.name) if File.exists?(t.name)
      end
    end

    desc "Force Recalc of dependencies"
    task :cleanDeps do
      All.depFiles.each {|f|FileUtils.rm(f)}
    end

  end
end
