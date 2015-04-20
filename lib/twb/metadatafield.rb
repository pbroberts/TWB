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

  class MetadataField

    attr_reader :node, :aggregation, :containsnull, :localname, :localtype, :ordinal, :parentname, :precision, :remotealias, :remotename, :remotetype, :width, :name

    def initialize fieldNode
      @node              = fieldNode
      @aggregation       = load 'aggregation'
      @containsnull      = load 'contains-null'
      @localname         = load 'local-name'
      @localtype         = load 'local-type'
      @ordinal           = load 'ordinal'
      @parentname        = load 'parent-name'
      @precision         = load 'precision'
      @remotealias       = load 'remote-alias'
      @remotename        = load 'remote-name'
      @name              = @remotename
      @remotetype        = load 'remote-type'
      @width             = load 'width'
      return self
    end

    def load nodeName
      node = @node.at_xpath(nodeName)
      val  = if node.nil? then  node else node.text end
      # puts "==== MD node:'#{nodeName}' \t nil?'#{node.nil?}' \t == val:#{val} \t = '#{node}' "
      return val
    end

  end

end



