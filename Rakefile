$:.unshift File.expand_path('../lib', __FILE__)
require 'offsite_payments/version'

begin
  require 'bundler'
  Bundler.setup
rescue LoadError => e
  puts "Error loading bundler (#{e.message}): \"gem install bundler\" for bundler support."
  require 'rubygems'
end

require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask'
require 'ci/reporter/rake/test_unit'

task :tag_release do
  system "git tag -a v#{OffsitePayments::VERSION} -m 'Tagging #{OffsitePayments::VERSION}'"
  system "git push --tags"
end

desc "Run the unit test suite"
task :default =>  ['ci:setup:testunit', 'test:units']
task :test =>  ['ci:setup:testunit', 'test:units']

namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.pattern = 'test/unit/**/*_test.rb'
    t.ruby_opts << '-rubygems'
    t.libs << 'test'
    t.verbose = true
  end

  Rake::TestTask.new(:remote) do |t|
    t.pattern = 'test/remote/**/*_test.rb'
    t.ruby_opts << '-rubygems'
    t.libs << 'test'
    t.verbose = true
  end
end
