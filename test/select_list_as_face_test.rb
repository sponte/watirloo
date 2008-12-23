require File.dirname(__FILE__) + '/test_helper'

describe "select list as semantic face object on a page" do
  
  before do
    @page = Watirloo::Page.new
    @page.b.goto testfile('select_lists.html')
    @page.add_face(
      :pets => [:select_list, :name, 'animals'],
      :gender => [:select_list, :name, 'sex_cd'])
  end
  
  it 'face method with key parameter to construct SelectList' do
    if @page.b.kind_of?(FireWatir::Firefox)
      @page.face(:pets).kind_of?(FireWatir::SelectList).should == true
      @page.face(:gender).kind_of?(FireWatir::SelectList).should == true
      
    elsif @page.b.kind_of? Watir::IE
      @page.face(:pets).kind_of?(Watir::SelectList).should == true
      @page.face(:gender).kind_of?(Watir::SelectList).should == true
    end
  end
  
  it 'face key as method matching modeling semantic object accessor' do
    if @page.b.kind_of?(FireWatir::Firefox)
      @page.pets.kind_of?(FireWatir::SelectList).should == true
      @page.gender.kind_of?(FireWatir::SelectList).should == true
      
    elsif @page.b.kind_of?(Watir::IE)
      @page.pets.kind_of?(Watir::SelectList).should == true
      @page.gender.kind_of?(Watir::SelectList).should == true
    end
    
  end
end
