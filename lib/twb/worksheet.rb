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

  class WorksheetDataSource
    attr_reader :node, :name, :caption, :uiname
    def initialize node
      @node   = node
      @caption = node.attr('caption')
      @name    = node.attr('name')
      @uiname  = if @caption.nil? || @caption == '' then @name else @caption end
    end
  end

  class Worksheet

    @@hasher = Digest::SHA256.new

    attr_reader :node, :name, :datasourcenames, :datasources

    def initialize sheetNode
      @node    = sheetNode
      @name    = @node.attr('name')
      loadDataSourceNames
      return self
    end

    def loadDataSourceNames
      @datasources = {}
      dsNodes = @node.xpath('.//datasource')
      dsNodes.each do |dsn|
        ds = WorksheetDataSource.new dsn
        @datasources[ds.name] = ds
      end
    end

    def datasources
      @datasources.values
    end

    def datasourcenames
      @datasources.keys
    end

  end

end