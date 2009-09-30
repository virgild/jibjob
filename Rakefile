# coding: utf-8
require 'spec/rake/spectask'

task :default => :spec

desc "Run specs"
task :spec do
  Spec::Rake::SpecTask.new do |t|
    t.rcov = true
    t.spec_opts = %w(--colour --format=specdoc --loadby mtime --reverse)
    t.spec_files = FileList['spec/*_spec.rb']
  end
end

namespace :package do
  desc "Clean Mac OS X extended file attributes"
  task :clean_attributes do
    `for i in $(ls -Rl@ | grep '^\t' | awk '{print $1}' | sort -u); do
      find . | xargs xattr -d $i 2>/dev/null;
     done
    `
  end
end

namespace :db do
  desc "Migrate database"
  task :migrate do
    require File.join(File.dirname(__FILE__), "lib/jibjob")
    require File.join(File.dirname(__FILE__), "lib/jibjob/migrations")
    JibJob::Migrations.migrate_up!
  end
end