require 'rubygems'
require 'spec/rake/spectask'
require 'rubygems/specification'
require 'rake/rdoctask'
require 'rake'

def gemspec
  @gemspec ||= begin
    gem_name = File.basename(File.dirname(__FILE__))
    file = File.expand_path("../#{gem_name}.gemspec", __FILE__)
    eval(File.read(file), binding, file)
  end
end

begin
  require 'rake/gempackagetask'
rescue LoadError
  task(:gem) { $stderr.puts '`gem install rake` to package gems' }
else
  Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.gem_spec = gemspec
  end
  task :gem => :gemspec
end

desc "Validates the gemspec"
task :gemspec do
  gemspec.validate
end

desc "Displays the current version"
task :version do
  puts "Current version: #{gemspec.version}"
end

desc "Installs the gem locally"
task :install => :package do
  sh "gem install pkg/#{gemspec.name}-#{gemspec.version}"
end

desc "Release the gem"
task :release => :package do
  sh "gem push pkg/#{gemspec.name}-#{gemspec.version}.gem"
end

Rake::RDocTask.new do |rdoc|
  files =['README.rdoc', 'COPYING', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.rdoc" # page to start on
  rdoc.title = "RubySesame Docs"
  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/*_spec.rb"].sort
  t.spec_opts = ["--options", "spec/spec.opts"]
end

desc "Run all specs and get coverage statistics"
Spec::Rake::SpecTask.new('coverage') do |t|
  t.spec_opts = ["--options", "spec/spec.opts"]
  t.spec_files = FileList["spec/*_spec.rb"].sort
  t.rcov_opts = ["--exclude", "spec", "--exclude", "gems"]
  t.rcov = true
end

task :default => :spec
