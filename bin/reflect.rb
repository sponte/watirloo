require File.join(File.dirname(__FILE__), '..','lib','reflector')

# simple implementation of reflector. Just reflect everything on the page.

ie = Watir::IE.attach(:url, //)

ie.reflect(:all).each do |r|
  puts r
end
