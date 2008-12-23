require File.dirname(__FILE__) + '/test_helper'

class CheckboxGroupPage < Watirloo::Page
  
  def pets
    @b.checkbox_group('pets')
  end
  
end

require 'watir/ie'
module Watir
  class CheckboxGroup
    
    def initialize(container, name)
      @container = container
      @name = name
      @o = @container.checkboxes.find_all {|cb| cb.name == @name}
    end
    
    def size
      @o.size
    end
    alias count size
    
    def hidden_values
      opts = []
      @o.each {|r| opts << r.ole_object.invoke('value')}
      return opts
    end
    
  end

  module Container
    def checkbox_group(name)
      CheckboxGroup.new(self, name)
    end
  end
  
end
describe 'checkbox group' do 
  before do
    @page = CheckboxGroupPage.new
    @page.b.goto testfile('checkbox_group1.html')
  end
  
  it 'collection of checkboxes sharing the same name' do
    @page.pets.kind_of?(Watir::CheckboxGroup).should == true
  end
  
  
  it 'size retuns checkboxes count in a group' do
    @page.pets.size.should == 5
   
  end
  
  it 'hidden values array' do
    @page.pets.hidden_values.should == ["cat", "dog", "zook", "zebra", "wumpa"]
  end
  
  
end