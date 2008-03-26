= ruby-kqueue

* FIX (url)

== DESCRIPTION:

Ruby bindings for the KQueue event framework

== FEATURES/PROBLEMS:

* Simple block based definition of event triggers.
* Unified interface for all event types.
* Supported filters: VNode

== SYNOPSIS:

  include RubyKQueue
  
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

== REQUIREMENTS:

* FreeBSD/OSX/Other KQueue supporting OS
* RubyInline + C compiler (I'll inline package soon enough)

== INSTALL:

* sudo gem install ruby-kqueue

== LICENSE:

(The MIT License)

Copyright (c) 2008 Kevin Clark

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
