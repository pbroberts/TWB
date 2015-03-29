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
require 'digest/md5'

module Twb

  class Dashboard

    @@hasher = Digest::SHA256.new

    attr_reader :node, :name, :worksheets, :autosize, :size, :maxheight, :maxwidth, :minheight, :minwidth, :rangesize, :dimensions, :zonecount

    def initialize dashboardNode, twbworksheets
      @node     = dashboardNode
      @name     = @node.attr('name')
      @size     = @node.xpath('./size')
      @autosize = @size.empty?
      loadSize @size unless @autosize
      loadSheets twbworksheets
      @zonecount = @node.xpath('.//zone').length
      return self
    end

    def loadSheets twbworksheets
      @sheets = {}
      dsheets = @node.xpath('.//zone[@name]').to_a
      dsheets.each do |sheetNode|
        sheetname = sheetNode.attr('name')
        @sheets[sheetname] = twbworksheets[sheetname]
      end
    end

    def worksheets
      @sheets.values
    end

    def loadSize size
      @maxheight  = size.attr('maxheight')
      @maxwidth   = size.attr('maxwidth')
      @minheight  = size.attr('minheight')
      @minwidth   = size.attr('minwidth')
      @rangesize  = size.attr('rangesize')
      @dimensions = @minwidth.to_s + ':' + @minheight.to_s + ':' +@maxwidth.to_s + ':' +@maxheight.to_s
    end

  end

end
