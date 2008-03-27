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
      
      Event.new(@dir, VNodeEvent, VNodeEvent::WRITE).trigger.should == 42
    
      # TODO: Deregister
    end
    
    it "should be triggered by an event" do      
      t = Thread.new { Event.handle }
      Event.register(@dir, VNodeEvent, VNodeEvent::WRITE) do
        $ret = 42
      end
      
      File.open("#{@dir}/writing", 'w+') {|f|}
      
      sleep 0.001
      
      $ret.should == 42
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
