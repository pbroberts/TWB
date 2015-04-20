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

    attr_reader :node, :name, :caption, :uiname, :connHash, :class, :connection, :tables, :localfields, :metadatafields

    def initialize dataSourceNode
      @node    = dataSourceNode
      @name    = @node.attr('name')
      @caption = @node.attr('caption')
      @uiname  = if @caption.nil? || @caption == '' then @name else @caption end
      processConnection
      processFields
      return self
    end

    def processConnection
      @connection  = @node.at_xpath('./connection')
      unless @connection.nil?
        @class       = @connection.attribute('class').text
        setConnectionHash
        loadTables @connection
      end
    end

    # Notes:
    #      - TODO: need to determine which, if any, of the connection attributes should be
    #              included in the hash in order to identify it unambiguously - without
    #              local values that obscure the data source's 'real' identity
    #      - attributes with value '' don't contribute to the hash
    def setConnectionHash
      dsAttributes = @node.xpath('./connection/@*')
      dsConnStr    = ''
      dsAttributes.each do |attr|
        dsConnStr += attr.text
      end
      @connHash = Digest::MD5.hexdigest(dsConnStr)
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

    def processFields
      # --
      @localfields    = {}
      nodes = @node.xpath(".//column")
      nodes.each do |node|
        field = Twb::LocalField.new(node)
        @localfields[field.name] = field
      end
      # --
      @metadatafields = {}
      nodes = @node.xpath("./connection/metadata-records/metadata-record")
      nodes.each do |node|
        field = Twb::MetadataField.new(node)
        @metadatafields[field.name] = field
      end
    end

    def field name
      field = if localfields[name].nil? then metadatafields[name] end
    end

  end

end