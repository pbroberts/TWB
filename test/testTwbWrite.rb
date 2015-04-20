# testTwbGem.rb - this Ruby script Copyright 2013, 2014 Christopher Gerrard

require 'nokogiri'

#require 'twb'
require 'C:\tech\Tableau\tools\Ruby\gems\twb\lib\twb.rb'

def processTWB twbWithDir
  print "\n\n\n      == #{twbWithDir}"
  twb     = Twb::Workbook.new twbWithDir
  puts " name     :: #{twb.name}"
  puts " class    :: #{twb.class}"
  puts " workbook?:: #{twb.instance_of?(Twb::Workbook)}"
  twb.writeAppend '.Documented'
  twb.writeAppend '....MultiLeadingPeriods'
end

puts "START"

path = if ARGV.empty? then '**/*.twb' else ARGV[0] end
puts "Looking for Workbooks matching: #{path}"
Dir.glob(path) {|twb| processTWB twb }

$f.close unless $f.nil?
