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

module Twb

  class FieldCalculation

    attr_reader :node, :formula, :fields, :comments, :class

    def initialize calcNode
      #puts "CALCNODE:: '#{calcNode}' -> #{calcNode.class}"
      if calcNode
        @node       = calcNode
       #-- Calculation --
        formulaCode     = calcNode.xpath('./@formula').text.gsub(/\r\n/, ' ')
        formulaLines    = calcNode.xpath('./@formula').text.split(/\r\n/)
        @formula        = getFormula(  formulaLines )
        @comments       = getComments( formulaLines )
        @class          = calcNode.xpath('./@class').text
        @scopeIsolation = calcNode.xpath('./@scope-isolation').text
       #-- Fields      --
        @fields   = parseFieldsFromFormula(formulaCode)
      end
    end
    
    def parseFieldsFromFormula formula
      fieldSet = Set.new []
      if formula =~ /\[.+\]/ then
          stripFrt =  formula.gsub( /^[^\[]*[\[]/    , '['      )
          stripBck = stripFrt.gsub( /\][^\]]+$/      , ']'      )
          stripMid = stripBck.gsub( /\][^\]]{2,}\[/  , ']]..[[' )
          stripCom = stripMid.gsub( /\][ ]*,[ ]*\[/  , ']]..[[' )
          fields   = stripCom.split(']..[')
          fields.each { |field| fieldSet.add field}
      end
      return fieldSet
    end

    def getFormula lines
      formula = ''
      lines.each do |line|
          line.strip
          formula += ' ' + line.gsub(/\/\/.*/, '') # unless line =~ /^[ ]*\/\//
      end
      return formula.strip
    end
    
    def getComments lines
      comments = ''
      lines.each do |line|
        if line =~ /\/\// then
          comments += ' ' + line.gsub(/^.*\/\//,'// ')
        end
      end
      return comments.strip
    end

  end

end
