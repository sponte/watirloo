require File.dirname(__FILE__) + '/test_setup'

describe "select list as semantic face object on a page" do
  
  before do
    @page = Watirloo::Page.new
    @page.b.goto testfile('select_lists.html')
    @page.add_face(
      :pets => [:select_list, :name, 'animals'],
      :gender => [:select_list, :name, 'sex_cd'])
  end
  
  it 'semantic value is the selected text visible to the user. when nothing selected value should be blank string' do
    @page.pets.value.should == ''
    @page.gender.value.should == ''
  end
  
  it 'semantic value is the selected text. after setting one item select the value should be a string that was set' do
    @page.pets.set 'dog'
    @page.pets.value.should == 'dog'
    @page.gender.set 'F'
    @page.gender.value.should == 'F'
  end

  it 'semantic value is the selected text. setting multiple items the value is an array of strings' do
    @page.pets.set ['cat', 'dog']
    @page.pets.value.should == ['cat','dog']
  end

  it 'setting multiple items for single select selects one in turn and value is the last item in array' do
    @page.gender.set ['M', 'F', '','F']
    @page.gender.value.should == 'F'
  end
  
  it 'setting single item after multiple items were set returns all values set for multiselect as array of strings' do
    @page.pets.set ['cat','zook']
    @page.pets.set 'zebra'
    @page.pets.value.should == ['cat', 'zook', 'zebra']
  end
  
  it 'clear methods deselects clears all selected items in multiselect' do
    @page.pets.set ['cat','zook']
    @page.pets.clear
    @page.pets.value.should == ''
  end

  it 'clear method removes selected attribute for item in single select list' do
    @page.gender.set 'F'
    @page.gender.value.should == 'F'
    @page.gender.clear
    @page.gender.value.should == '' # This fails on IE. it does not remove selected attribute from option
  end
  
  it 'user can select by option value using watir methods' do
    @page.gender.select_value 'm'
    @page.gender.value.should == 'M'
    @page.pets.select_value 'o2'
    @page.pets.select_value 'o4'
    @page.pets.value.should == ['dog', 'zebra']
  end
  
end
