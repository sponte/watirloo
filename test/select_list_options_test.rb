require File.dirname(__FILE__) + '/test_helper'

describe "select list page objects options as actual values not visible to the user" do
  
  before do
    @page = Watirloo::Page.new
    @page.b.goto testfile('select_lists.html')
    @page.add_face(
      :pets => [:select_list, :name, 'animals'],
      :gender => [:select_list, :name, 'sex_cd'],
      :toys => [:select_list, :name, 'bubel'])
  end

  it 'options by face key method' do
    @page.face(:gender).hidden_values.should == ['', 'm', 'f']
    @page.face(:pets).hidden_values.should == ['o1', 'o2', 'o3', 'o4', 'o5']
  end
  
  it 'options by method name matching face key' do
    @page.gender.hidden_values.should == ['', 'm', 'f']
    @page.pets.hidden_values.should == ['o1', 'o2', 'o3', 'o4', 'o5']
  end
  
  it 'options with no value attribute' do
    # in case of IE it will return all blanks
    @page.toys.hidden_values.should == ["", "", "", "", ""]
    # for Firfox it returns actual items ["", "foobel", "barbel", "bazbel", "chuchu"]
    # known failure on Firefox
  end
  
  it 'options with no value attribute return items' do
    @page.toys.items.should == ["", "foobel", "barbel", "bazbel", "chuchu"]
  end
  
  
end