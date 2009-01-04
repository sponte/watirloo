gem 'watir', '>=1.6.2'
require 'watir'
require 'watir/ie'

module Watir
  
  module RadioCheckGroupCommon
    
    def values
      opts = []
      @o.each {|r| opts << r.ole_object.invoke('value')}
      return opts
    end
    
    def size
      @o.size
    end
    alias count size
    
    # sets Radio||Checkbox in a group by either position in a group or by hidden value attribute 
    def set(what)
      if what.kind_of?(Array)
        what.each {|el| set el } #calls itself with Fixnum or String
      else
        if what.kind_of?(Fixnum)
          get_by_position(what).set
        elsif what.kind_of?(String)
          get_by_value(what).set
        else
          raise ::Watir::Exception::WatirException, "argument error #{what} not allowed"
        end
      end
    end
    
    #returns Radio||Checkbox from a group that has specified value attribute set to provided value text
    def get_by_value value
      if values.member? value
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
    
  end
  # radios that share the same name form a RadioGroup. 
  # RadioGroup models the behavior of that set as an Object
  # You can access RadioGroup with the radio_group method and name attribute
  # just like you access radio.
  # usage: Watir::Container#radio_group method returns this object
  # RadioGroup semantically behaves like single select list box.
  # per html4.1 an item needs to be preselected in radio group. 
  # There can not be radio group with all items off. At least one needs to be on by default.
  # The idea of having all radios off makes no sense but in the wild you can see lots of examples.
  # it would be better to just have a single select list box with no items selected instead of radios.
  # The point of having radios is that at least one radio is on providing a default value for the group
  # 
  #   @browser = Watir::IE.attach :url, //
  #   @browser.radio_group('food') # => RadioGroup
  class RadioGroup
    
    include RadioCheckGroupCommon
    
    def initialize(container, name)
      @container = container
      @name = name
      @o = @container.radios.find_all {|r| r.name == @name}
    end
    
    # which value is selected?
    def selected_value
      selected_radio.ole_object.invoke('value')
    end
    
    # returns radio that is selected.
    # there can only be one radio selected. 
    # in the event that none is selected it returns nil
    def selected_radio
      @o.find {|r| r.isSet?}
    end
    alias selected selected_radio
    
  end
  
  # Checkbox group semantically behaves like multi select list box.
  # each checkbox is a menu item groupped by the common attribute :name
  # each checkbox can be off initially (a bit different semantics than RadioGroup)
  class CheckboxGroup
    
    include RadioCheckGroupCommon
    
    def initialize(container, name)
      @container = container
      @name = name
      @o = @container.checkboxes.find_all {|cb| cb.name == @name}
    end
    
    # returns selected checkboxex as array
    # [] = nothing selected
    # [checkbox, checkbox] = checkboxes that are selected.
    def selected_checkboxes
      @o.select {|cb| cb.isSet?}
    end
    alias selected selected_checkboxes
    
    def selected_values
      values = []
      selected_checkboxes.each do |cb|
        values << cb.ole_object.invoke('value')
      end
      return values
    end
    
  end

  
  module Container
    def radio_group(name)
      RadioGroup.new(self, name)
    end
      
    def checkbox_group(name)
      CheckboxGroup.new(self, name)
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
      return case a.size #TODO find if nil is better than empty string
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