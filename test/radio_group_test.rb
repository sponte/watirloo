require File.dirname(__FILE__) + '/test_helper'

class RadioGroupPage < Watirloo::Page
  # array of radios sharing the same name
  # the following works on IE but not on firefox    
  # @b.radios.find_all {|r| r.name == 'food'} 
  # find_all is undefined for radios method
  # the solution is to do radios.each implementation
  # returns array of radios sharing the same name
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

describe 'food_group as RadioGroup class' do

  before do
    @page = RadioGroupPage.new
    @page.b.goto testfile('radio_group.html')
  end
  
  it 'container radio_group method returns RadioGroup class' do
    if @page.b.kind_of?(FireWatir::Firefox)
      @page.food_group.kind_of?(FireWatir::RadioGroup).should.be true
      
    elsif @page.b.kind_of?(Watir::IE)
      @page.food_group.kind_of?(Watir::RadioGroup).should.be true
    end
  end
  
  it 'size or count returns how many radios in a group' do
    @page.food_group.size.should == 3
    @page.food_group.count.should == 3
  end
  
  it 'values returns value attributes text items as an array' do
    @page.food_group.values.should == ["hotdog", "burger", "tofu"]
  end
  
  it 'selected_value returns internal option value for selected radio item in a group' do 
    @page.food_group.selected_value.should == 'burger'
  end
  
  it 'set selects radio by position in a group' do
    @page.food_group.set 3
    @page.food_group.selected_value.should == 'tofu'
    @page.food_group.set 1
    @page.food_group.selected_value.should == 'hotdog'
  end
  
  it 'set selects radio by value in a group' do
    @page.food_group.set 'hotdog'
    @page.food_group.selected_value.should == 'hotdog'
    @page.food_group.set 'tofu'
    @page.food_group.selected_value.should == 'tofu'
  end
  
  it 'set position throws exception if number not within the range of group size' do
    assert_raise(Watir::Exception::WatirException) do
      @page.food_group.set 7
    end
  end
  
  it 'set value throws exception if value not found in options' do
    assert_raise(Watir::Exception::WatirException) do
      @page.food_group.set 'banannnanna'
    end
  end
  
  # TODO do I want to provide mapping of human generated semantic values for radios 
  # to actual values here in the radio_group or at the Watirllo level only? 
  it 'set throws exception if other than Fixnum or String element is used' do
    assert_raise(Watir::Exception::WatirException)do
      @page.food_group.set :yes
    end
  end
  
end