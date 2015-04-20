# testTwbGem.rb - this Ruby script Copyright 2013, 2014 Christopher Gerrard

require 'nokogiri'

#require 'twb'
require 'C:\tech\Tableau\tools\Ruby\gems\twb\lib\twb.rb'

def processTWB twbWithDir
  print "\n\n\n== #{twbWithDir}"
  twb     = Twb::Workbook.new twbWithDir
  puts " :: #{twb.name}"
  doc =  twb.ndoc

  puts "  Data Sources"
  twb.datasources.each do |ds|
    puts "\n\t    n\t- #{ds.name}\n\t :: c\t- #{ds.caption}\n\t :: uin\t- #{ds.uiname} \n\t :: ch\t- #{ds.connHash}\n\t :: p?\t- #{ds.Parameters?} "
    puts   "\t tbls\t- #{ds.tables}"
    ds.localfields.each do |name,fld|
      puts   "\t\t lfld:\t- #{name}"
    end
    ds.metadatafields.each do |name,fld|
      puts   "\t\t mfld:\t- #{name} = #{fld.localname} = #{fld}"
    end
  end

  puts "\n  Dashboards ...."
  puts "\t     \t-#{twb.dashboardNames}"
  twb.dashboards.each do |dsh|
    puts "\n\t    n\t- #{dsh.name} \t zc:#{dsh.zonecount} \t auto? #{dsh.autosize}  \t dim: #{dsh.dimensions} "
    dsh.worksheets.each do |sheet|
      puts "\t     s\t  - #{sheet.name} \t dsnames:#{sheet.datasourcenames} "
    end
  end

  puts "\n  Worksheets ...."
  puts "\t     \t-#{twb.worksheetNames}"
  twb.worksheets.each do |ws|
    puts "\t    n\t-#{ws.name}"
    ws.datasourcenames.each do |dsn|
      puts "\t        ds:\t- #{dsn}"
    end
  end

  puts "\n  Storyboards ...."
  puts "\t     \t-#{twb.storyboardNames}"
  if twb.storyboards
    twb.storyboards.each do |sb|
      puts "\t    n\t-#{sb.name} "
      sb.worksheets.each do |sheet|
        puts "\t    n\t  -#{sheet} "
      end
    end
  end

end

def getName techName
    techName.gsub(/^\[/,'').gsub(/\]$/,'')
end

puts "START"

path = if ARGV.empty? then '**/*.twb' else ARGV[0] end
puts "Looking for Workbooks matching: #{path}"
Dir.glob(path) {|twb| processTWB twb }

$f.close unless $f.nil?
