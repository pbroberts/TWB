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

require_relative 'twb/dashboard'
require_relative 'twb/datasource'
require_relative 'twb/docdashboard'
require_relative 'twb/fieldcalculation.rb'
require_relative 'twb/localfield'
require_relative 'twb/metadatafield'
require_relative 'twb/storyboard'
require_relative 'twb/util/htmllistcollapsible'
require_relative 'twb/util/xraydashboards'
require_relative 'twb/window'
require_relative 'twb/workbook'
require_relative 'twb/worksheet'

# Represents Tableau Workbooks and their contents.
#
module Twb
  VERSION = '0.0.37'
end

