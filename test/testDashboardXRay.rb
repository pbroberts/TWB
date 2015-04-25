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
require "test/unit"

system "cls"

class TestDashboardXRays < Test::Unit::TestCase

  def test_create
    print "\n\n\n      == #{'Web Page Dashboards.twb'}"
    twb     = Twb::Workbook.new('Web Page Dashboards.twb')
    puts " name     :: #{twb.name}"
    puts " class    :: #{twb.class}"
    puts " workbook?:: #{twb.instance_of?(Twb::Workbook)}"
    xrayer = Twb::DashboardXRayer.new(twb)
    assert(!xrayer.nil?)
    puts "xrayer.methods\n=============\n#{xrayer.methods}"
    xrays = xrayer.xray
    assert(!xrays.nil?)
    puts "\n\nDashboards:: #{xrays.keys}"
    xrays.each do |dash, html|
      htmlfilename =  twb.name + '.' + dash.to_s
      saveHTML(htmlfilename, html)
    end
  end
  
  def saveHTML(htmlfilename, html)
    begin
      puts "\n\n htmlfilename :: #{htmlfilename}"
      htmlfile = File.open(htmlfilename + '.html', 'w')
      htmlfile.puts html
      htmlfile.close
    rescue
      cleanfilename = sanitize(htmlfilename) + '.html'
      puts     "              :: #{cleanfilename} \n\n"
      saveHTML(cleanfilename, html)
    end
  end

  def sanitize(str)
    puts "     Sanitize :: #{str}"
    cleanStr = str.gsub(/[^a-z0-9\-]+/i, ' ')
  end

end
