$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'watirloo/watir_ducktape'
require 'watirloo/reflector'

module Watirloo

  VERSION = '0.0.1'
  
  # Generic Semantic Test Object
  module TestObject
    attr_accessor :id, :desc
  
  end

  # browser. we return IE or Firefox. Safari? Other Browser?
  class BrowserHerd 
    include TestObject
    
    @@target = :ie #default target

    def self.target=(indicator)
      @@target = indicator
    end
    
    def self.target
      @@target
    end
    
    #provide browser
    def self.browser
      case @@target
      when :ie 
        Watir::IE.attach :url, // #this attach is a crutch
      when :firefox
        gem 'firewatir', '>=1.6.2' # dependency
        require 'firewatir'
        require 'watirloo/firewatir_ducktape'
        # this is a cruch for quick work with pages.
        # in reality you want to create a browser and pass it as argument to initialize Page class
        FireWatir::Firefox.attach #this attach is a crutch
      end
    end
  end
  
  # Semantic Page Objects Container.
  # page objects are defined as faces of a Page.
  # Each face (aka Interface of a page) is accessed by page.facename or page.face(:facename) methods
  # Pages make Watir fun
  class Page
    
    include TestObject
    attr_accessor :b
    attr_reader :faces

    # by convention the Page just attaches to the first available browser.
    # the smart thing to do is to manage browsers existence on the desktop separately
    # and supply Page class with the instance of browser you want for your tests.
    # &block is the convenience at creation time to do some work.
    # example:
    #   browser = Watir::start("http://mysitetotest")
    #   page = Page.new(browser) # specify browser instance to work with or
    #   page = Page.new # just let the page do lazy thing and attach itself to browser.
    # part of this page initialization is to provide a convenience while developing tests where
    # we may have only one browser open and that's the one browser were we want to talk to.
    def initialize(browser = Watirloo::BrowserHerd.browser , &blk)
      @b = browser
      @faces = {}
      instance_eval(&blk) if block_given? # allows the shortcut to do some work at page creation
    end
  
    # enter values on controls idenfied by keys on the page.
    # data map is a hash, key represents the page object,
    # value represents its value to be set, either text, array or boolean
    def spray(dataMap)
      dataMap.each_pair do |face_symbol, value|
        get_face(face_symbol).set value #make every element in the dom respond to set to set its value
      end
    end
  
    # return Watir object given by its semantic face symbol name
    def get_face(face_symbol)
      if self.respond_to? face_symbol # if there is a defined wrapper method for page element provided
        return self.send(face_symbol) 
      elsif @faces.member?(face_symbol) # pull element from @faces and send to browser
        method, *args = @faces[face_symbol] # return definition for face consumable by browser
        return @b.send(method, *args)
      else
        #??? I ran out of ideas
      end
    end
    alias face get_face
  
    # add face definition to page
    def add_face(definitions)
      if definitions.kind_of?(Hash)
        @faces.update definitions  
      end
    end
  
    # Delegate execution to browser if no method or face defined on page class
    def method_missing method, *args
      if @b.respond_to? method
        @b.send method, *args
      elsif  @faces.member?(method.to_sym)
        get_face(method.to_sym)
      else
        raise Watir::Exception::WatirException # I ran out of ideas!
      end
    end
  end

end