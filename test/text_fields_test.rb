require File.dirname(__FILE__) + '/test_helper'

describe "add faces text fields page objects" do
  
  before do
    @page = Watirloo::Page.new
    @page.b.goto testfile('person.html')
  end

  it 'faces initially is an empty Hash' do
    @page.faces.should == {}
  end
  
  it 'add_face accepts keys as semantic faces and values as definitions to construct Watir Elements' do
    @page.add_face(
      :last => [:text_field, :name, 'last_nm'],
      :first => [:text_field, :name, 'first_nm'])
    @page.faces.size.should == 2
    #TODO TextField should be Watir and independent of Browser IE, FireFox or others.
    if @page.b.kind_of? FireWatir::Firefox
      @page.face(:first).kind_of?(FireWatir::TextField).should == true
      @page.face(:last).kind_of?(FireWatir::TextField).should == true
      
    elsif @page.b.kind_of? Watir::IE
      @page.face(:first).kind_of?(Watir::TextField).should == true
      @page.face(:last).kind_of?(Watir::TextField).should == true
    end
  end
end

describe "text fields page objects setting and getting values" do

  before do
    @page = Watirloo::Page.new
    @page.goto testfile('person.html')
    @page.add_face(
      :last => [:text_field, :name, 'last_nm'],
      :first => [:text_field, :name, 'first_nm']
    )
  end

  it "face name keyword and value returns current text" do
    @page.face(:first).value.should == 'Joanney'
    @page.face(:last).value.should == 'Begoodnuffski'
  end
  
  it 'face name method and value returns current text' do
    @page.first.value.should == 'Joanney'
    @page.last.value.should == 'Begoodnuffski'    
  end
  
  it "face name kewords and set enters value into field" do
    params = {:first => 'Grzegorz',:last => 'Brzeczyszczykiewicz'}
    @page.face(:first).set params[:first]
    @page.face(:last).set params[:last]
    @page.face(:first).value.should == params[:first]
    @page.face(:last).value.should == params[:last]  
  end
  
  it "face name method and set enters value into field" do
    params = {:first => 'Grzegorz',:last => 'Brzeczyszczykiewicz'}
    @page.first.set params[:first]
    @page.last.set params[:last]
    @page.first.value.should == params[:first]
    @page.last.value.should == params[:last]  
  end
  
  it 'spray values match semantic keys to faces and set their values' do
    @page.spray :first => 'Hermenegilda', :last => 'Kociubinska'
    @page.face(:first).value.should == 'Hermenegilda'
    @page.face(:last).value.should == 'Kociubinska'
  end
end
 