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

require 'twb'
require "test/unit"

system "cls"

class TestDocDash < Test::Unit::TestCase
 
  def test_create
    vDash = Twb::DocDashboardWebVert.new
    assert(!vDash.nil?, "Doc Dashboard creation should not be null")
    assert_equal('columnar Web Page', vDash.type)
    assert(!vDash.dashnode.nil?, "Doc Dashboard dashboard node should not be null")
    assert(!vDash.winnode.nil?, "Doc Dashboard window node should not be null")
    assert(!vDash.dashnode.at_xpath('.//zone[@type="web"]').nil?, " <dashboard Web zone must not be null")
    assert(!vDash.winnode.at_xpath('.//zone[@type="web"]').nil?,  " <window Web zone must not be null")
  end
  
  def test_assignname
    vDash = Twb::DocDashboardWebVert.new
    vDash.title=('test title name')
    assert_equal('test title name', vDash.title)
    assert(!vDash.dashnode.attribute('name').nil?)
    assert(!vDash.winnode.attribute('name').nil?)
    assert_equal('test title name', vDash.dashnode.attribute('name').value)
    assert_equal('test title name', vDash.winnode.attribute('name').value)
  end
 
  def test_assigurl
    vDash = Twb::DocDashboardWebVert.new
    vDash.url=('test URL')
    assert_equal('test URL', vDash.url)
  end
  
  def test_inject
    vDash = Twb::DocDashboardWebVert.new
    vDash.title=('Injected Documentation Dashboard')
    vDash.url=('http://localhost:8808/doc_root/nokogiri-1.5.5-x86-mingw32/rdoc/Nokogiri/XML/Node.html#method-i-add_next_sibling')
    do_injection(vDash, 'No Content.twb')
    vDash.title=('Collapsible List of Workook Contents')
    vDash.url=('file:///C:/tech/misc/expandable_tree_view/TableauDocInlineCSS.html')
    do_injection(vDash, 'No Dashboards.twb')
    do_injection(vDash, 'Web Page Dashboards.twb')
  end
  
  def do_injection(dash, twbName)
    twb   = Twb::Workbook.new(twbName)
    assert(!twb.nil?)
    twb.addDocDashboard dash
    twb.writeAppend('injected')
  end
 
end