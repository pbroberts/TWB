# testTwbGem.rb - this Ruby script Copyright 2013, 2014 Christopher Gerrard

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
