require 'rake'
require 'rake/testtask'
require 'rdoc/task'

GEMSPEC_FILE = 'mprofi_api_client.gemspec'


Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  #t.verbose = true
end

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.main = 'README.md'
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb", "LICENSE")
end

desc 'Build gem'
task :build do
  sh "bundle exec gem build #{GEMSPEC_FILE}"
end
