gem 'watir', '>=1.6.2'
require 'watir'
require 'watir/ie'

module Watir
  
  # radios that share the same name form a RadioGroup. 
  # RadioGroup models the behavior of that set as an Object
  # access using :radio_group method
  # usage: Watir::Container#radio_group method returns this object
  # 
  #   @browser = Watir::IE.attach :url, //
  #   @browser.radio_group('food') # => RadioGroup
  
  class RadioGroup
    
    def initialize(container, name)
      @container = container
      @name = name
      @o = @container.radios.find_all {|r| r.name == @name}
    end
    
    def hidden_values
      opts = []
      @o.each {|r| opts << r.ole_object.invoke('value')}
      return opts
    end
    
    def size
      @o.size
    end
    alias count size
    
    # which value is selected?
    def selected_hidden_value
      selected_radio.ole_object.invoke('value')
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
        @o.find {|r| r.ole_object.invoke('value') == value}
      else
        raise ::Watir::Exception::WatirException, "value #{value} not found in hidden_values"
      end
    end
    
    def get_by_position position
      if (0..self.size).member? position
        @o[position-1]
      else
        raise ::Watir::Exception::WatirException, "positon #{position} is out of range of #{size} items"
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
  
  class RadioCheckCommon
    alias set? isSet?
  end
  
  # There are two kinds of SelectLists. singleselect and multi select
  # select list presents user with visible items to select from.
  # Each Item has a visible :text and invisible :value attributes
  # In Watirloo
  # The invisible :value attribute text we call option
  # The visible :text we call :item
  # The selected item we call :value
  # 
  # example of single select list
  # 
  #   <select name="controlname">
  #     <option value="opt0"></option>
  #     <option value="opt1">item1</option>
  #     <option value="opt2" selected>item2</option>
  #   </select> 
  #   
  # items => ['', 'item1', 'item2']
  # options => ['opt0','opt1', 'opt2']
  # value => 'item2'
  # 
  # example of multi select list
  #   <select name="controlname" multiple size=2>
  #     <option value="o1">item1
  #     <option value="o2" selected>item2
  #     <option value="o3" selected>item3
  #   </select>
  # items => ['item1', 'item2', 'item3']
  # options => ['o1','o2','o3']
  # value => ['item2', 'item3'] # array of selected items by text
  #
  class SelectList
    
    # value returns the selected text item or items.
    # either empty string for nothing selected.
    # string if there is one value selected
    # or array of values selected in multiselect list
    # example select_list.value = '' # => select list has item with text '' selected or multiselect list has no values set
    def value
      a = getSelectedItems
      return case a.size
      when 0 then ''
      when 1 then a[0]
      else a
      end
    end
    
    # accepts one text item or array of text items. if array then sets one after another. 
    # For single select lists the last item in array wins
    def set(item)
      if item.kind_of? Array
        item.each do |single_item|
          select_item_in_select_list(:text, single_item)
        end
      else
        select_item_in_select_list(:text, item)
      end
    end
    
    # each option may have a value attribute which is hidden to the person viewing the  page
    def hidden_values
      a = []
      attribute_value('options').each do |item|
        a << item.value
      end
      return a
    end
    
    alias clear clearSelection
    alias items getAllContents
  end
end