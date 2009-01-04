require File.dirname(__FILE__) + '/test_helper'

class CheckboxGroupPage < Watirloo::Page
  # semantic wrapper for the radio group object
  def pets
    @b.checkbox_group('pets')
  end
end


describe 'checkbox group semantic access' do 
  
  before do
    @page = CheckboxGroupPage.new
    @page.b.goto testfile('checkbox_group1.html')
  end
  
  it 'checkbox_group container method returns CheckboxGroup class' do
    # let's check explicitly for test purpose what Class is we are dealing with
    # if IE then Watir::CheckboxGroup
    # if FF then FireWatir::CheckboxGroup
    if @page.b.kind_of?(FireWatir::Firefox)
      @page.pets.kind_of?(FireWatir::CheckboxGroup).should == true
      
    elsif  @page.b.kind_of?(Watir::IE)
      @page.pets.kind_of?(Watir::CheckboxGroup).should == true
    end
  end
  
  it 'size retuns checkboxes as items count in a group' do
    @page.pets.size.should == 5
  end
  it 'values returns array of value attributes for each checkbox in a group' do
    @page.pets.values.should == ["cat", "dog", "zook", "zebra", "wumpa"]
  end
  
  it 'selected_values returns array of value attributes of each selected checkbox' do
    @page.pets.selected_values.should == []
  end
  
  it 'set String checks the checkbox in a group where value is String' do
    @page.pets.set 'dog'
    @page.pets.selected_values.should == ['dog']
    @page.pets.set 'zebra'
    @page.pets.selected_values.should == ['dog', 'zebra']    
  end
  
  it 'set String array checks each checkbox by hidden value String' do
    @page.pets.set ['dog', 'zebra', 'cat'] # not in order
    @page.pets.selected_values.should == ['cat', 'dog', 'zebra']
  end
  
  it 'set Fixnum checks checkbox by position in a group. Position is 1 based' do
    @page.pets.set 3
    @page.pets.selected_values.should == ['zook']
    @page.pets.set 2
    @page.pets.selected_values.should == ['dog','zook']
    
  end
  
  it 'set array of Fixnums checks each checkbox by position' do
    @page.pets.set [1,2,4]
    @page.pets.selected_values.should == ["cat", "dog", "zebra"]
  end
  
end