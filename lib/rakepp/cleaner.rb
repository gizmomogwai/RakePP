class Cleaner
  def initialize()
    desc "Clean all artifacts"
    task :clean do
      Rake::Task.tasks.reverse_each do | t |
        FileUtils.rm_rf(t.name) if File.exists?(t.name)
      end
    end
  end
end
