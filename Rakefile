# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/ruby-kqueue.rb'

Hoe.new('ruby-kqueue', RubyKQueue::VERSION) do |p|
  p.developer('Kevin Clark', 'kevin.clark@gmail.com')
end

begin
  require 'spec'
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new do |t|
    t.warning = true
    # t.rcov = true
  end
rescue LoadError
end

# vim: syntax=Ruby
