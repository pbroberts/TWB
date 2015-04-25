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

  # Assumption: A field can only be either a MetadataField or a LocalField, not both in a given Workbook data connection.

  class LocalField

    attr_reader :type, :node, :name, :datatype, :role, :type, :hidden, :caption, :aggregation, :uiname, :calculation

    def initialize fieldNode
      @node        = fieldNode
      @type        = 'local'
      @name        = @node.attr('name')
      @datatype    = @node.attr('datatype')
      @role        = @node.attr('role')
      @type        = @node.attr('type')
      @hidden      = @node.attr('hidden')
      @caption     = @node.attr('caption')
      @aggregation = @node.attr('aggregation')
      @calculation = getCalculation(node)
      @uiname      = if @caption.nil? || @caption == '' then @name else @caption end
      return self
    end
    
    def getCalculation node
      FieldCalculation.new(node.at_xpath("./calculation"))
    end

  end

end
