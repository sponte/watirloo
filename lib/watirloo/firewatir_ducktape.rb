require 'firewatir'

module FireWatir
  
  # duck punch Firefox for Watirloo needs
  class Firefox
    
    # attach to the existing Firefox that was already started with JSSH option.
    # this is a hack for Watirloo. it only attaches to the latest firefox.
    # it assumes there is only one instance of FF window open on the desktop
    def self.attach
      Firefox.new :attach => true
    end
    
    # add option key :attach as a hack
    # :attach => true to attach to topmost window in getWindows().lenght-1
    def initialize(options = {})
      _start_firefox(options) unless options[:attach]
      set_defaults()
      get_window_number()
      set_browser_document()
    end
    
    
    def _start_firefox(options)
      if(options.kind_of?(Integer))
        options = {:waitTime => options}
      end
      
      if(options[:profile])
        profile_opt = "-no-remote -P #{options[:profile]}"
      else
        profile_opt = ""
      end
      
      waitTime = options[:waitTime] || 2
      
      case RUBY_PLATFORM 
      when /mswin/
        # Get the path to Firefox.exe using Registry.
        require 'win32/registry.rb'
        path_to_bin = ""
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Mozilla\Mozilla Firefox') do |reg|
          keys = reg.keys
          reg1 = Win32::Registry::HKEY_LOCAL_MACHINE.open("SOFTWARE\\Mozilla\\Mozilla Firefox\\#{keys[0]}\\Main")
          reg1.each do |subkey, type, data|
            if(subkey =~ /pathtoexe/i)
              path_to_bin = data
            end
          end
        end
        
      when /linux/i
        path_to_bin = `which firefox`.strip
      when /darwin/i
        path_to_bin = '/Applications/Firefox.app/Contents/MacOS/firefox'
      when /java/
        raise "Not implemented: Create a browser finder in JRuby"
      end
      
      @t = Thread.new { system("#{path_to_bin} -jssh #{profile_opt}")}   
      sleep waitTime
      
    end
    private :_start_firefox

  end

  class SelectList
    
    # FIXME this is the duplicate code from Watir::SelectList
    def value
      a = getSelectedItems
      return case a.size
      when 0 then ''
      when 1 then a[0]
      else a
      end
    end

    # FIXME this is dupcliate code from Watir::SelectList
    def set(item)
      if item.kind_of? Array
        item.each do |single_item|
          select_item_in_select_list(:text, single_item)
        end
      elsif item.kind_of? String
        select_item_in_select_list(:text, item)
      end
    end
    
    def hidden_values
      a = []
      items.each do |item|
        a << option(:text, item).value
      end
      return a
    end
    
    alias clear clearSelection
    alias items getAllContents
  end

  class RadioGroup
    
    def initialize(container, name)
      @container = container
      @name = name
      @o = []
      @container.radios.each do |r| #TODO find why find_all does not work
        if r.name == @name
          @o << r
        end
      end
      return @o
    end
    
    def hidden_values
      opts = []
      @o.each {|r| opts << r.value}
      return opts
    end
    
    def size
      @o.size
    end
    alias count size
    
    # which value is selected?
    def selected_hidden_value
      selected_radio.value
    end
    
    def set(what)
      if what.kind_of?(Fixnum)
        get_by_position(what).set
      elsif what.kind_of?(String)
        get_by_value(what).set
      else
        raise ::Watir::Exception::WatirException, "argument error #{what} not allowed"
      end
    end
    
    def get_by_value value
      if hidden_values.member? value
        @o.find {|r| r.value == value}
      else
        raise ::Watir::Exception::WatirException, "value #{value} not found in hidden values"
      end
    end
    
    def get_by_position position
      if (0..self.size).member? position
        @o[position-1]
      else
        raise ::Watir::Exception::WatirException, "positon #{position} is out of range of size"
      end 
    end
    
    def selected_radio
      @o.find {|r| r.isSet?}
    end
  end
  
  module Container
    def radio_group(name)
      RadioGroup.new(self, name)
    end
  end
end