#  Copyright (C) 2014, 2015  Chris Gerrard
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
