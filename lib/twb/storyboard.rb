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

  class Storyboard

    @@hasher = Digest::SHA256.new

    attr_reader :node, :name, :worksheets

    def initialize node
      # puts "initialize Storyboard"
      @node    = node
      @name    = @node.attr('name')
      loadSheets
    end

    def loadSheets
      @sheets = {}
      sheets = @node.xpath('.//story-point').to_a
      sheets.each do |node|
        @sheets[node.attr('captured-sheet')] = node.attr('captured-sheet')
      end
    end

    def worksheets
      @sheets.values
    end

  end

end
