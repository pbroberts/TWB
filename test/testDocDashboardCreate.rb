# testTwbGem.rb - this Ruby script Copyright 2013, 2014 Christopher Gerrard

require 'nokogiri'

#require 'twb'
require 'C:\tech\Tableau\tools\Ruby\gems\twb\lib\twb.rb'


vDash = Twb::DocDashboardWebVert.new
vDash.title='Test Web Page Doc Dashboard'

vDash.url='new dashboard URL'

=begin
hDash = Twb::DocDashboardWebHoriz.new
hDash.title='across'

puts "Vert: #{vDash} -> #{vDash.type} \t - #{vDash.title} \ndashnode:\n #{vDash.dashnode} \n\nwinnode: #{vDash.winnode}\n\n\n"
puts "horz: #{hDash} -> #{hDash.type} \t - #{hDash.title}"

def loadDash type
  print "init new dash '#{type}'\t: "
  dash = Twb::DocDashboard.new(type)
  puts "#{dash} :: #{dash.nil?}"
  puts "#{if dash.nil? then 'nope' else dash.type end}"
end

loadDash 'v'
loadDash 'vert'
loadDash 'tical'
loadDash 'vertical'
loadDash 'veert'
=end
