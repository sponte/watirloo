require File.dirname(__FILE__) + '/test_helper'

describe "select list as semantic face object on a page" do
  
  before do
    @page = Watirloo::Page.new
    @page.b.goto testfile('select_lists.html')
    @page.add_face(
      :pets => [:select_list, :name, 'animals'],
      :gender => [:select_list, :name, 'sex_cd'])
  end
  
  it 'face method with key parameter to construct SelectList per browser implementation' do
    if @page.b.kind_of?(FireWatir::Firefox)
      @page.face(:pets).kind_of?(FireWatir::SelectList).should == true
      @page.face(:gender).kind_of?(FireWatir::SelectList).should == true
      
    elsif @page.b.kind_of? Watir::IE
      @page.face(:pets).kind_of?(Watir::SelectList).should == true
      @page.face(:gender).kind_of?(Watir::SelectList).should == true
    end
  end
  
  it 'face(:facename) and browser.select_list access the same control' do
    @page.b.select_list(:name, 'sex_cd').values.should == @page.gender.values
    @page.b.select_list(:name, 'animals').values.should == @page.pets.values
  end
  
  
  it 'face(:facename) and facename access the same control' do
    @page.face(:gender).items.should == @page.gender.items
    @page.face(:pets).items.should == @page.pets.items
  end

  it 'facename method matching modeling semantic object accessor' do
    if @page.b.kind_of?(FireWatir::Firefox)
      @page.pets.kind_of?(FireWatir::SelectList).should == true
      @page.gender.kind_of?(FireWatir::SelectList).should == true
      
    elsif @page.b.kind_of?(Watir::IE)
      @page.pets.kind_of?(Watir::SelectList).should == true
      @page.gender.kind_of?(Watir::SelectList).should == true
    end
    
  end
end
