require File.join( File.dirname(__FILE__), "spec_helper" )
require 'fileutils'

module RubyKQueue
  describe Event do
    it "should register and trigger events without watching" do
      Event.register("/tmp", VNodeEvent, VNodeEvent::WRITE) do
        42
      end
      
      Event.new("/tmp", VNodeEvent, VNodeEvent::WRITE).trigger.should == 42
    
      # TODO: Deregister
    end
    
    it "should register and trigger events when watching" do
      FileUtils.rm_rf '/tmp/blaa'
      
      $ret = nil
      
      t = Thread.new { Event.handle }
      Event.register("/tmp", VNodeEvent, VNodeEvent::WRITE) do
        $ret = 42
      end
      
      File.open('/tmp/blaa', 'w+') {|f|}
      
      sleep 0.001
      
      $ret.should == 42
    end
  end
end
