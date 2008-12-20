require File.dirname(__FILE__) + '/../lib/watirloo'

# all tests attach to an existing firefox browser
# start browser with jssh option
# I assume you have firewatir >= 1.6.2 installed
Watir::Browser.default='firefox'
Watir::Browser.new
Watirloo::BrowserHerd.target = :firefox
tests = Dir["#{File.dirname(__FILE__)}/*_test.rb"]
tests.each {|t|require t}

# at the end of tests you will have one extra browser open