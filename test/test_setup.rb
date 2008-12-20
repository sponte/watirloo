require File.dirname(__FILE__) + '/../lib/watirloo'
require 'test/spec'
#Watirloo::BrowserHerd.target = :firefox

def testfile(filename)
  path = File.expand_path(File.dirname(__FILE__))
  uri = "file://#{path}/html/" + filename
  return uri
end