require 'rubygems'
require 'securerandom'
require 'fileutils'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
end

desc('Clean tests')
task(:clean) do
  begin
    File.delete('db/test.sqlite3')
    FileUtils.rm_r('public/test')
  rescue Errno::ENOENT
    puts 'No test files to clean.'
  end
end

desc('Random token')
task(:random) do
  puts SecureRandom.hex
end

task(:default => [:test, :clean])