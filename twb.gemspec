$:.push File.expand_path("../lib", __FILE__)
require 'twb'

Gem::Specification.new do |s|
  s.name        = 'twb'
  s.summary     = "Classes for accessing Tableau Workbooks and their contents - summary."
  s.description = "Classes for accessing Tableau Workbooks and their contents - description"
  s.version     = Twb::VERSION
  s.date        = "2015-03-14"
  s.author      = "Chris Gerrard"
  s.email       = "Chris@Gerrard.net"
  s.files       = Dir['**/**']
  s.homepage    = 'http://rubygems.org/gems/twb'
  s.license     = 'GNU General Public License v3.0'
end