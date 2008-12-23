require File.dirname(__FILE__) + '/test_helper'

class RadioGroupPage < Watirloo::Page
  # array of radios sharing the same name
  # the following works on IE but not on firefox    
  # @b.radios.find_all {|r| r.name == 'food'} 
  # find_all is undefined for radios method
  # the solution is to do radios.each implementation
  def food
    o = []
    @b.radios.each do |r|
      if r.name == 'food'
        o << r
      end
    end
    return o
  end

  # RadioGroup Class (yes, collection of radios sharing the same name but as class)
  def food_group
    @b.radio_group('food')
  end
end

describe 'radio group access method for set of radios' do

  before do
    @page = RadioGroupPage.new
    @page.b.goto testfile('radio_group.html')
  end
  
  it 'radio_group returns RadioGroup clas' do
    if @page.b.kind_of?(FireWatir::Firefox)
      @page.food_group.kind_of?(FireWatir::RadioGroup).should.be true
      
    elsif @page.b.kind_of?(Watir::IE)
      @page.food_group.kind_of?(Watir::RadioGroup).should.be true
    end
  end
  
  it 'size or count returns how many radios in a group' do
    @page.food.size.should == 3
    @page.food_group.size.should == 3
    @page.food_group.count.should == 3
  end
  
  it 'options returns value attributes as an array' do
    @page.food_group.hidden_values.should == ["hotdog", "burger", "tofu"]
  end
  
  it 'value returns internal option value for selected radio item in a group' do 
    # return by finding the set item and get its value
    # the following find with ole_object does not work on firefox
    #@page.food.find {|r| r.isSet?}.ole_object.invoke('value').should == 'burger' 
    # get value of radio group
    @page.food_group.selected_hidden_value.should == 'burger'
  end
  
  it 'set selects radio by position in a group' do
    @page.food_group.set 3
    @page.food_group.selected_hidden_value.should == 'tofu'
    @page.food_group.set 1
    @page.food_group.selected_hidden_value.should == 'hotdog'
  end
  
  it 'set selects radio by value in a group' do
    @page.food_group.set 'hotdog'
    @page.food_group.selected_hidden_value.should == 'hotdog'
  end
  
  it 'set position throws exception if number not within the range of group size' do
    assert_raise(Watirloo::WatirlooException) do
      @page.food_group.set 7
    end
  end
  
  it 'set value throws exception if value not found in options' do
    assert_raise(Watirloo::WatirlooException) do
      @page.food_group.set 'banannnanna'
    end
  end
  
  # TODO do I want to provide mapping of human generated semantic values for radios 
  # to actual values here in the radio_group or at the Watirllo level only? 
  it 'set accepts only Fixnum or String' do
    assert_raise(Watirloo::WatirlooException)do
      @page.food_group.set :yes
    end
  end
  
end