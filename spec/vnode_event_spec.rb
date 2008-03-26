require File.join( File.dirname(__FILE__), "spec_helper" )

module RubyKQueue
  describe VNodeEvent do
    it "should define VNODE filter and associated constants" do
      ['EVFILT_VNODE', 'NOTE_DELETE', 'NOTE_WRITE', 'NOTE_EXTEND',
      'NOTE_ATTRIB', 'NOTE_LINK' , 'NOTE_RENAME', 'NOTE_REVOKE'].each do |const|
        VNodeEvent.const_get(const).should_not == nil
      end
    end
  end
end
