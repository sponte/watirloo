gem 'watir', '>=1.6.2'
require 'watir'
require 'watir/ie'

module Watir
  
  # for firefox and ie
  module RadioCheckGroupCommonWatir
    
    # size or count of controls in a group
    def size
      @o.size
    end
    alias count size

    # sets control in a group by either position in a group 
    # or by hidden value attribute 
    def set(what)
      if what.kind_of?(Array)
        what.each {|thing| set thing } #calls itself with Fixnum or String
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

    # returns array of value attributes
    def values
      raise ::Watir::Exception::WatirException, "method should be implemented"
    end

    # returns Radio||Checkbox from a group that
    #  has specific value attribute 
    def get_by_value value
      raise ::Watir::Exception::WatirException, "method should be implemented"
    end
    
    # returns Radio||Checkbox from a group that
    # occupies specifi position in a group
    # WARNING: it is 1-based NOT 0-based
    # the intention is to enumerate position staring with 1, the way
    # customer would enumerate items
    def get_by_position position
      if (1..self.size).member? position
        @o[position-1]
      else
        raise ::Watir::Exception::WatirException, "positon #{position} is out of range of size"
      end 
    end
  end
  
  # for IE only
  module RadioCheckGroup
       
    def values
      opts = []
      @o.each {|r| opts << r.ole_object.invoke('value')}
      return opts
    end
    
    def get_by_value value
      if values.member? value
        @o.find {|r| r.ole_object.invoke('value') == value}
      else
        raise ::Watir::Exception::WatirException, "value #{value} not found in hidden_values"
      end
    end
  end

  #for firefox and ie
  module RadioGroupCommonWatir

    # Only one radio in RadioGroup can be selected just like
    # only one option in single select list box can be selected.
    # this method is a bit gratuitious because it will always return array
    # with one item but it's here to keep the plural for compatibility with 
    # CheckboxGroup or SelectList. if at some point your page object gets changed from RadioGroup
    # to SelectList your tests will not have to change
    def selected_values
      selected_value.to_a
    end
    
    
    # returns radio that is selected.
    # there can only be one radio selected. 
    # in the event that none is selected it returns nil
    # see selected_value commentary
    def selected_radio
      @o.find {|r| r.isSet?}
    end
  end

  # radios that share the same :name attribute form a RadioGroup. 
  # RadioGroup semantically behaves like single select list box
  # usage: this class is accessed by Watir::Container#radio_group 
  # RadioGroup semantically behaves like single select list box.
  # 
  # per HTML401: -  
  #   "If no radio button in a set sharing the same control name 
  #   is initially 'on', user agent behavior for choosing which 
  #   control is initially 'on' is undefined
  # 
  # The idea of having all radios off makes no sense but in the wild you can see lots of examples.
  # it would be better to just have a single select list box with no items selected instead of radios.
  # The point of having radios is that at least one radio is 'ON' providing a default value for the group
  # 
  #   @browser = Watir::IE.attach :url, //
  #   @browser.radio_group('food') # => RadioGroup with :name, 'food'
  # 
  class RadioGroup
    
    include RadioCheckGroupCommonWatir
    include RadioCheckGroup
    include RadioGroupCommonWatir
    
    def initialize(container, name)
      @container = container
      @name = name
      @o = @container.radios.find_all {|r| r.name == @name}
    end
    
    # which value is selected?. returns value text as string
    # So per HTML401 spec I am not sure if we should ever have empyt array returned here
    # if you do get empty array then I would speak with developers to fix this and explicity 
    # provide checked for one radio on page load.
    def selected_value
      selected_radio.ole_object.invoke('value')
    end

    # in the absence of visible text like in select list we treat value
    # as a selected text invisible to the user
    alias selected selected_value

  end
  
  
  module CheckboxGroupCommonWatir

    # returns selected checkboxex as array
    # [] = nothing selected
    # [checkbox, checkbox] = checkboxes that are selected.
    def selected_checkboxes
      @o.select {|cb| cb.isSet?}
    end
    
    # convinience method as a filter for select_values
    # returns: 
    #   nil => when no checkbox is set
    #   'value' => if one checkbox is set
    #   or bypass filter and return selected_values array
    def selected_value
      arr = selected_values
      case arr.size
      when 0 then nil
      when 1 then arr[0]
      else arr      
      end
    end
    
    # in case of checkbox there are no visible text items. 
    # We rely on value attributes that must be present 
    # to differentiate the checkbox in a group
    # compare to SelectList where selected returns selected_item
    alias selected selected_value

  end

  # Checkbox group semantically behaves like multi select list box.
  # each checkbox is a menu item groupped by the common attribute :name
  # each checkbox can be off initially (a bit different semantics than RadioGroup)
  class CheckboxGroup
    
    include RadioCheckGroupCommonWatir
    include RadioCheckGroup
    include CheckboxGroupCommonWatir
    
    def initialize(container, name)
      @container = container
      @name = name
      @o = @container.checkboxes.find_all {|cb| cb.name == @name}
    end
    
    # returns array of value attributes. Each Checkbox in a group 
    # has a value which is invisible to the user
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
  
  # these methods work for IE and for Firefox
  module SelectListCommonWatir

    # selected_items examples
    #   [] =>  nothing selected
    #   ['item'] => if one selected
    #   ['item1', 'item2', 'item3'] => several items selected
    def selected_items 
      getSelectedItems
    end
    
    # selected_item is a convenience filter for selected_items
    # returns
    #   nil if no options selected
    #   'text' string if one option selected.
    #   or selected_items if more than one option selected
    def selected_item
      arr = selected_items # limit to one mehtod call
      case arr.size
      when 0 then nil
      when 1 then arr[0]
      else arr
      end
    end
    
    
    # for selecte lists by default we return the text of an option
    # compare to selected in RadioGroup or Checkbox group which return the 
    # value attributes since there is no visible text for the user
    alias selected selected_item
    
    # set :value or :text
    def _set(how, what)
      if what.kind_of? Array
        what.each { |item| _set(how,item)} # call self with individual item
      else
        if what.kind_of? Fixnum # if by position then translate to set by text
          if (0..items.size).member? what
            _set :text, items[what-1]
          else
            raise ::Watir::Exception::WatirException, "number #{item} is out of range of item count"
          end 
        else
          select_item_in_select_list(how, what)  #finally as :value or :text
        end
      end
      
    end
    private :_set
    


    
    # similar to selected_items but returns array of option value attributes
    def selected_values
      assert_exists
      arr = []
      @o.each do |thisItem|
        if thisItem.selected
          arr << thisItem.value
        end
      end
      return arr
    end
    
    # convinience method as a filter for select_values
    # returns: 
    # nil for nothing selected. 
    # single value if only once selected or just
    # or returns selected_values
    def selected_value
      arr = selected_values
      case arr.size
      when 0 then nil
      when 1 then arr[0]
      else arr      
      end
    end
    
 
  end
  
  # SelectList acts like RadioGroup or CheckboxGroup
  # They all have options to select
  # There are two kinds of SelectLists. SingleSelect and MultiSelect
  # SelectList presents user with visible items to select from.
  # Each Item has a visible :text and invisible :value attributes
  # (sometimes :value attributes are missing)
  # 
  # In Watirloo
  # The invisible :value attributes of options  we call :values
  # The visible :text of options we call :items
  # The selected items as visible text we call :selected
  # The selected items as values  we call :selected_values
  # 
  # example of single select list
  # 
  #   <select name="controlname">
  #     <option value="opt0"></option>
  #     <option value="opt1">item1</option>
  #     <option value="opt2" selected>item2</option>
  #   </select> 
  #   
  #   items => ['', 'item1', 'item2']
  #   values => ['opt0','opt1', 'opt2']
  #   selected => ['item2']
  #   selected_values => ['opt2']
  #    
  # example of multi select list
  # 
  #   <select name="controlname" multiple size=2>
  #     <option value="o1">item1
  #     <option value="o2" selected>item2
  #     <option value="o3" selected>item3
  #   </select>
  #   
  #   items => ['item1', 'item2', 'item3']
  #   values => ['o1','o2','o3']
  #   selected => ['item2', 'item3']
  #   selected_values => ['o2', 'o3']
  # 
  class SelectList
    
    include SelectListCommonWatir

        
    # accepts one text item or array of text items. if array then sets one after another. 
    # For single select lists the last item in array wins
    # 
    # examples
    #   select_list.set 'bla' # => single option text
    #   select_list.set ['bla','foo','gugu'] # => set 3 options by text. If 
    #       this is a single select list box it will set each value in turn
    #   select_list set 1 # => set the first option in a list
    #   select_list.set [1,3,5] => set the first, third and fith options
    def set(item)
      _set(:text, item)
    end

    # set item by the option value attribute. if array then set one after anohter.
    # see examples in set method
    def set_value(value)
      _set(:value, value)
    end
    
    # returns array of value attributes
    # each option usually has a value attribute 
    # which is hidden to the person viewing the page
    def values
      a = []
      attribute_value('options').each do |item|
        a << item.value
      end
      return a
    end

    alias clear clearSelection
    
    # alias, items or contents return the same visible text items
    alias items getAllContents

  end
end