require File.dirname(__FILE__) + '/test_setup'

describe 'setting and getting values for individual checkboxes with value attributes in face definitions' do
  
  before do
    @page = Watirloo::Page.new
    @page.goto testfile('checkbox_group1.html')
    @page.add_face(
      :pets_cat => [:checkbox, :name, 'pets', 'cat'],
      :pets_dog => [:checkbox, :name, 'pets', 'dog'],
      :pets_zook => [:checkbox, :name, 'pets', 'zook'],
      :pets_zebra => [:checkbox, :name, 'pets', 'zebra'],
      :pets_wumpa => [:checkbox, :name, 'pets', 'wumpa'])
  end
  
  it 'semantic name accesses individual CheckBox' do
    if @page.b.kind_of?(FireWatir::Firefox)
      @page.face(:pets_cat).kind_of?(FireWatir::CheckBox).should == true
      
    elsif @page.b.kind_of?(Watir::IE)
      @page.face(:pets_cat).kind_of?(Watir::CheckBox).should == true
    end
  end
  
  it 'set individual checkbox does not set other checkboxes sharing the same name' do
    @page.face(:pets_dog).checked?.should == false
    @page.face(:pets_dog).set
    @page.face(:pets_dog).checked?.should == true
    @page.face(:pets_cat).checked?.should == false
  end
  
  it 'by default all are false. set each unchecked checkbox should have checked? true' do
    @page.faces.keys.each do |key|
      @page.face(key).checked?.should == false
    end

    @page.faces.keys.each do |key|
      @page.face(key).set
    end
    
    @page.faces.keys.each do |key|
      @page.face(key).checked?.should.be true    
    end
  end
  
end
