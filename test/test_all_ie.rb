require File.dirname(__FILE__) + '/../lib/watirloo'

# all tests use attach method to a browser that exist on the desktop
# open new ie browser
Watir::Browser.default = 'ie'
Watir::Browser.new

tests = Dir["#{File.dirname(__FILE__)}/*_test.rb"]
tests.each {|t|require t}

#at the end of tests you will have one  browser open