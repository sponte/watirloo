require 'watirloo'
# simple implementation of reflector. Just reflect everything on the page.

ie = Watir::IE.attach(:url, //)

ie.reflect(:all).each do |r|
  puts r
end
