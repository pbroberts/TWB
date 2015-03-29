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

  class DataSource

    @@hasher = Digest::SHA256.new

    attr_reader :node, :name, :caption, :uiname, :connHash, :class, :connection, :tables

    def initialize dataSourceNode
      @node    = dataSourceNode
      @name    = @node.attr('name')
      @caption = @node.attr('caption')
      @uiname  = if @caption.nil? || @caption == '' then @name else @caption end
      processConnection
      return self
    end

    def processConnection
      @connHash    = ''
      @connection  = @node.at_xpath('./connection')
      unless @connection.nil?
        @class       = @connection.attribute('class').text
        dsAttributes = @node.xpath('./connection/@*')
        dsConnStr    = ''
        dsAttributes.each do |attr|
          dsConnStr += attr.text
          # Note: '' attributes with value '' don't contribute to the hash
        end
        @connHash = Digest::MD5.hexdigest(dsConnStr)
        loadTables @connection
      end
    end

    def loadTables connection
      @tables = {}
      nodes = connection.xpath(".//relation[@type='table']")
      nodes.each do |node|
        @tables[node.attr('name')] = node.attr('table')
      end
    end

    def Parameters?
      @name == 'Parameters'
    end

  end

end