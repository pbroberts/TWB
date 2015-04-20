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

    # Creates a Workbook, from its file name.
    #
    # == Parameters:
    # twbWithDir
    #   The Workbook's file name
    #
    def initialize twbWithDir
      @name    = File.basename(twbWithDir)
      @dir     = File.dirname(File.expand_path(twbWithDir))
      @modtime = File.new(twbWithDir).mtime
      @ndoc    = Nokogiri::XML(open(twbWithDir))
      @wbnode  = @ndoc.at_xpath('//workbook')
      @version = @ndoc.xpath('/workbook/@version')
      @build   = @ndoc.xpath('/workbook/comment()').text.gsub(/^[^0-9]+/,'').strip
      loaddatasources
      loadWorksheets
      loadDashboards
      loadStoryboards
      loadWindows
      return true
    end

    def loaddatasources
      @dataSources = @ndoc.at_xpath('//workbook/datasources')
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
      @dashesNode = @ndoc.at_xpath('//workbook/dashboards')
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

    def loadWindows
      @windowsnode = @ndoc.at_xpath("//workbook/windows")
      @windows = {}
      windows  = @ndoc.xpath("//workbook/windows/window[@name]")
      windows.each do |node|
        window = Twb::Window.new(node)
        @windows[window.name] = window
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
    
    # Make sure that the TWB has a <dashboards> node.
    # It's possible for a TWB to have no dashboards, and therefore no <dashboards> node.
    def ensureDashboardsNodeExists
      if @dashesNode.nil?
        @dashesNode = Nokogiri::XML::Node.new "dashboards", @ndoc
        @dataSources.add_next_sibling(@dashesNode)
      end
    end

    def ensureWindowsNodeExists
      if @windowsnode.nil?
        @windowsnode = Nokogiri::XML::Node.new "windows", @ndoc
        @dataSources.add_next_sibling(@windowsnode)
      end
    end

    # Add a new Documentation Dashboard to the TWB.
    # Ensure that the TWB has a <dashboards> node (it may not).
    # Make sure that the new Doc Dashboard's name doesn't conflict with an existing Dashboard - increment the incoming name if necessary.
    # Add Doc Dashboard's <dashboard> and <window> nodes to the TWB; there's always a <windows> node in the TWB.
    def addDocDashboard docDashboard
      ensureDashboardsNodeExists
      ensureWindowsNodeExists
      title = getNewDashboardTitle(docDashboard.title)
      docDashboard.title=(title) unless title == docDashboard.title
      @dashesNode.add_child(docDashboard.dashnode)
      @windowsnode.add_child(docDashboard.winnode)     
    end
 
    def getNewDashboardTitle(t)
      title = t
      if @datasources.include?(title)
        inc = 0
        loop do
          inc+=1
          title = t + ' ' + inc.to_s
          if !@datasources.include?(title)
            break
          end
        end
      end
      return title
    end

    # Write the TWB to a file, with an optional name.
    # Can be used to write over the existing TWB (dangerous), or to a new file (preferred).
    def write(name=@name)
      $f = File.open(name,'w')
      if $f
          $f.puts @ndoc
          $f.close
      end
    end
   
    # Write the TWB to a file, appending the base name with the provided string.
    # Intended for use when making adjustments to the TWB without overwriting the original.
    def writeAppend(str)
      newName = @name.sub(/[.]twb$/,'') + str.gsub(/^[.]*/,'.') + '.twb'
      write newName
    end

  end

end