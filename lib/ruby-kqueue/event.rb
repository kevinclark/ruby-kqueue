module RubyKQueue
  class Event
    inline do |builder|
      builder.include "<sys/event.h>"
      builder.include "<sys/time.h>"
      builder.include "<errno.h>"
      
      builder.prefix <<-"END"
        static int kq;
        static VALUE cRubyKQueue;
        static VALUE cKqueueEvent;
        static VALUE m_trigger;
        
        #define MAX_EVENTS 10
      END
      
      builder.add_to_init <<-"END"
        kq = kqueue();
        cRubyKQueue = rb_const_get(rb_cObject, rb_intern("RubyKQueue"));
        cKqueueEvent = rb_const_get(cRubyKQueue, rb_intern("Event"));
        
        m_trigger = rb_intern("trigger");
        
        if (kq == -1) {
          rb_raise(rb_eStandardError, "kqueue initilization failed");
        }
      END
      
      builder.c_singleton <<-"END"
        VALUE c_register(VALUE ident, VALUE filter, VALUE fflags) {
          struct kevent new_event;
          
          EV_SET(&new_event, FIX2INT(ident), FIX2INT(filter),
                 EV_ADD | EV_ENABLE, FIX2INT(fflags), 0, 0);
          
          if (-1 == kevent(kq, &new_event, 1, NULL, 0, NULL)) {
            rb_raise(rb_eStandardError, strerror(errno));
          }
          
          return Qnil;
        }
      END
      
      builder.c_singleton <<-"END"
        VALUE c_handle_events() {
          int nevents, i, num_to_fetch;
          struct kevent *events;
          fd_set read_set;
      
          FD_ZERO(&read_set);
          FD_SET(kq, &read_set);
      
          // Don't actually run this method until we've got an event
          rb_thread_select(kq + 1, &read_set, NULL, NULL, NULL);  
      
          num_to_fetch = MAX_EVENTS;
          events = (struct kevent*)malloc(num_to_fetch * sizeof(struct kevent));
      
          if (NULL == events) {
            rb_raise(rb_eStandardError, strerror(errno));
          }
      
          nevents = kevent(kq, NULL, 0, events, num_to_fetch, NULL);
      
          if (-1 == nevents) {
            free(events);
            rb_raise(rb_eStandardError, strerror(errno));
          } else {
            for (i = 0; i < nevents; i++) {
              rb_funcall(cKqueueEvent, m_trigger, 3, INT2NUM(events[i].ident), INT2NUM(events[i].filter), INT2NUM(events[i].fflags));
            }
          }
      
          free(events);
      
          return INT2FIX(nevents);
        }
      END
    end
    
    @@registry = {}
    
    def self.register(ident, filter_class, *flags, &block)
      ident = filter_class.transform_ident(ident)
      filter = filter_class::FILTER
      
      @@registry[filter] ||= {}
      @@registry[filter][ident] ||= {}
        
      flags.each do |flag|
        @@registry[filter][ident][flag] = block
      end
      
      mask = flags.inject {|msk, flg| msk | flg }
      
      c_register(ident, filter, mask)
    end
    
    def self.trigger(id, filter, flag)
      Event.new(id, filter, flag).trigger
    end
    
    def self.handle
      c_handle_events
    end
    
    def self.registry
      @@registry
    end
    
    def self.respond_to?(item, *args)
      case item
      when Event
        self.registry[item.filter][item.id][item.flag].respond_to?(:call) rescue false
      else
        super
      end
    end
    
    def self.normalize_ident(ident)
      ident
    end
    
    attr_reader :id, :filter, :flag
    
    def initialize(id, filter_or_filter_class, flag)      
      if filter_or_filter_class.is_a? Class
        @id = filter_or_filter_class.transform_ident(id)
        @filter = filter_or_filter_class::FILTER
      else
        @id = id
        @filter = filter_or_filter_class
      end
      
      @flag = flag
    end
    
    def trigger
      if self.class.respond_to? self
        self.class.registry[filter][id][flag].call(self)
      else
        $stderr.puts "Trigger got an event it didn't respond to. Bug?"
        # ignore or raise?
      end
    end
            
  end
end