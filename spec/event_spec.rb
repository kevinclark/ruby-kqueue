require File.join( File.dirname(__FILE__), "spec_helper" )
require 'fileutils'

module RubyKQueue  
  describe "Event with a single flag" do
    before(:all) do
      @dir = "/tmp/ruby_kqueue_test"
      FileUtils.mkdir_p @dir rescue nil
    end

    before(:each) do
      $ret = nil
      FileUtils.rm_rf "#{@dir}/*"
    end

    after(:all) do
      FileUtils.rm_rf "#{@dir}"
    end
    
    it "should register and trigger" do
      Event.register(@dir, VNodeEvent, VNodeEvent::WRITE) do
        42
      end
      
      ev = Event.new(@dir, VNodeEvent, VNodeEvent::WRITE)
      
      ev.trigger.should == 42
      
      ev.deregister
      
      ev.trigger.should == nil
    end
    
    it "should be triggered by an event if registered" do
      t = Thread.new { Event.handle }
      Event.register(@dir, VNodeEvent, VNodeEvent::WRITE) do
        $ret = 42
      end
      
      File.open("#{@dir}/writing", 'w+') {|f|}
      sleep 0.00001
      $ret.should == 42
      
      Event.deregister(@dir, VNodeEvent, VNodeEvent::WRITE)
      $ret = nil
      
      File.open("#{@dir}/writing_again", 'w+') {|f|}
      sleep 0.00001
      $ret.should == nil
    end
  end
  
  # describe "Event with multiple flags" do
  #   it "should register and trigger from each flag" do
  #     Event.register("/tmp", VNodeEvent, VNodeEvent::WRITE, VNodeEvent::READ) do
  #       42
  #     end
  #     
  #     Event.new("/tmp", VNodeEvent, VNodeEvent::Write)
  #   end
  #   
  # end
end
