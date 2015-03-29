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


  # Represents Tableau Workbooks and their parts.
  #
  class Workbook

    attr_reader :name, :dir, :modtime, :version, :build, :ndoc, :datasources, :dashboards, :storyboards, :worksheets

    # Creates a Workbook, from it's file name.
    #
    # == Parameters:
    # twbWithDir
    #   The Workbook's file name
    #
    def initialize twbWithDir
      file     = File.new(twbWithDir)
      @name    = File.basename(twbWithDir)
      @dir     = File.dirname(File.expand_path(twbWithDir))
      @modtime = File.new(twbWithDir).mtime
      @ndoc = Nokogiri::XML(open(twbWithDir))
      @version = @ndoc.xpath('/workbook/@version')
      @build   = @ndoc.xpath('/workbook/comment()').text.gsub(/^[^0-9]+/,'').strip
      loaddatasources
      loadWorksheets
      loadDashboards
      loadStoryboards
      return true
    end

    def loaddatasources
      @datasources = {}
      @datasourceNodes = @ndoc.xpath('//workbook/datasources/datasource').to_a
      @datasourceNodes.each do |node|
        datasource = Twb::DataSource.new(node)
        @datasources[datasource.name] = datasource
      end
      return true
    end

    def loadWorksheets
      @worksheets = {}
      sheets = @ndoc.xpath('//workbook/worksheets/worksheet' ).to_a
      sheets.each do |node|
        sheet = Twb::Worksheet.new(node)
        @worksheets[sheet.name] = sheet
      end
    end

    def loadDashboards
      @dashboards = {}
      dashes = @ndoc.xpath('//workbook/dashboards/dashboard' ).to_a
      dashes.each do |node|
        unless node.attr('type') == 'storyboard' then
          dashboard = Twb::Dashboard.new(node, @worksheets)
          @dashboards[dashboard.name] = dashboard
        end
      end
    end

    def loadStoryboards
      @storyboards = {}
      boards = @ndoc.xpath("//workbook/dashboards/dashboard[@type='storyboard']" ).to_a
      boards.each do |node|
        sheet = Twb::Storyboard.new(node)
        @storyboards[sheet.name] = sheet
      end
    end


    def datasources
      @datasources.values
    end

    def dashboards
      @dashboards.values
    end

    def storyboards
      @storyboards.values
    end

    def worksheets
      @worksheets.values
    end


    def datasourceNames
      @datasources.keys
    end

    def dashboardNames
      @dashboards.keys
    end

    def storyboardNames
      @storyboards.keys
    end

    def worksheetNames
      @worksheets.keys
    end


    def datasource name
      @datasources[name]
    end

    def dashboard name
      @dashboards[name]
    end

    def storyboard name
      @storyboards[name]
    end

    def worksheet name
      @worksheets[name]
    end

  end

end