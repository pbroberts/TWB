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
require 'set'

module Twb

  class DocDashboard

  @@types = Set.new( ['h', 'horiz', 'horizontal',
                      'v', 'vert',  'vertical'   ] )

  attr_reader :title, :dashnode, :winnode, :type #, :panels, :autosize, :size
  
  def title=(title)
    @title = title
    @dashnode['name'] = title
    @winnode['name']  = title
  end

  def size=(size)
    @size = size
  end

  def initialize type
    dashboard = if @@types.include?(type)
                then if type[0] == 'v'
                     then DocDashboardVert.new
                     else DocDashboardHoriz.new
                     end
                else nil
                end
    return dashboard
  end
  
  def to_s
    return @title + ' :: ' + @type
  end

  end

  class DocDashboardWebVert < DocDashboard
    
    attr_reader :url 
    
    def initialize
      @oneColWebPageDash = Nokogiri::XML::Document.parse <<-ONECOlWEBDASH
      <dashdoc>
        <dashboard name='Single Column Web Page Automatic'>
          <style></style>
          <zones>
            <zone h='100000' id='3' param='vert' type='layout-flow' w='100000' x='0' y='0'>
              <zone h='6221' id='1' type='title' w='100000' x='0' y='0'></zone>
              <zone h='93157' id='4' param='horz' type='layout-flow' w='100000' x='0' y='6221'>
                <zone forceUpdate='' h='93157' id='6' param='URL' type='web' w='99655' x='0' y='6221'></zone>
              </zone>
            </zone>
          </zones>
        </dashboard>
        <window auto-hidden='0' class='dashboard' maximized='1' name='Single Column Web Page Automatic'>
          <zones>
            <zone h='6221' id='1' name='' type='title' w='100000' x='0' y='0' />
            <zone forceUpdate='' h='93157' id='5' name='' param='Web Page' type='web' w='50000' x='50000' y='6221' />
          </zones>
        </window>
      </dashdoc>
      ONECOlWEBDASH
      # notes:
      #  - adding a size element to the <dashboard element will change it from automatic, e.g.
      #
      #    <dashboard name='One Column Web Page Laptop (800w 600h)'>
      #    <style>
      #    </style>
      #    <size maxheight='600' maxwidth='800' minheight='600' minwidth='800' />
      #
      #  - the 'name' sttributes for the window and dashboard must match
      @type = 'columnar Web Page'
      @dashnode = @oneColWebPageDash.at_xpath('//dashboard')
      @winnode  = @oneColWebPageDash.at_xpath('//window')
    end
    
    def title=(title)
      @title = title
      @dashnode['name'] = title
      @winnode['name']  = title
    end
    
    def url=(url)
        dashwebzone = @dashnode.at_xpath('.//zone[@type="web"]')
        dashwebzone['param'] = url # unless dashwebzone.nil? 
        winwebzone  = @winnode.at_xpath('.//zone[@type="web"]')
        winwebzone['param'] = url  # unless winwebzone.nil?
    end
    
    def url
        dashurl = @dashnode.at_xpath('.//zone[@type="web"]').attribute('param').value
        winurl  = @winnode.at_xpath( './/zone[@type="web"]').attribute('param').value
        @url = if dashurl == winurl then dashurl end
    end

  end

  class DocDashboardWebHoriz < DocDashboard
    def initialize
      @type = 'horizontal'
    end
  end

end
