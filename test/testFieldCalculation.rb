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

class TestFieldCalculation < Test::Unit::TestCase

  def test_fragment1
    doc = Nokogiri::XML::Document.parse <<-EOHTML
<calculation class='tableau' formula='abc' />
EOHTML
    calcNode = doc.at_xpath('./calculation')
    calc = Twb::FieldCalculation.new(calcNode)
    assert(!calc.nil?)
    #puts "node: #{calcNode}"
    #puts "formula: #{calc.formula}"
    fields = calc.fields
    #puts "fields: #{fields.length}"
    assert(!fields.nil?,'Calculation fields must not be nil.')
    assert(fields.empty?,'Calculation fields must be empty.')
  end


  def test_fragment2
    doc = Nokogiri::XML::Document.parse <<-EOHTML
        <calculation class='tableau' formula='// this is the number of days between the order and shipment&#13;&#10;&#13;&#10;datediff(&apos;day&apos;,[Order Date] , [other].[Ship Date])' />
EOHTML
    calcNode = doc.at_xpath('./calculation')
    calc = Twb::FieldCalculation.new(calcNode)
    assert(!calc.nil?)
    #puts "node: #{calcNode}"
    #puts "formula: #{calc.formula}"
    fields = calc.fields
    #puts "fields: #{fields.length}"
    #fields.each {|e| puts "FIELD: #{e} "}
    assert(!fields.nil?,'Calculation fields must not be nil.')
    assert(!fields.empty?,'Calculation fields must not be empty.')
    assert_equal(fields.length,2,'There must be 2 fields.')
  end

  
  def xtest_create
    puts "\n\n\n      == Calculated Fields Test Workbook.twb"
    twb     = Twb::Workbook.new('Calculated Fields Test Workbook.twb')
    assert_equal(twb.name, 'Calculated Fields Test Workbook.twb')
    assert(twb.instance_of?(Twb::Workbook))
    dataSources = twb.datasources
    assert(!dataSources.empty?)
    dataSources.each do |ds|
      fields = ds.localfields
      assert(!fields.empty?)
      fields.each do |f|
        #puts "\nFIELD\n-----\n#{f}"
        field = Twb::LocalField
      end
    end
  end
  

end
