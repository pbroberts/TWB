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


  class DashboardXRayer

    @@typeLabels = {
                    'bitmap'       => 'Image',
                    'color'        => 'Color Legend',
                    'currpage'     => 'Pages Control',
                    'draw'         => 'Draw',
                    'empty'        => 'Blank',
                    'filter'       => 'Filter',
                    'layout-basic' => 'Layout - Basic',
                    'layout-flow'  => 'Layout - Flow',
                    'map'          => 'Map Legend',
                    'mru-entry'    => 'Mru Entry',
                    'paramctrl'    => 'Parameter',
                    'shape'        => 'Shape Legend',
                    'size'         => 'Size Legend',
                    'text'         => 'Text',
                    'text-block'   => 'Text Block',
                    'title'        => 'Title',
                    'web'          => 'Web Page'
                  }

    @@zoneNamePadText  = '&ndash;'

    @@shapeRadius = 1000
    @@shapeDiam   = 2*@@shapeRadius

    @@htmlTableLead  = '<p style="font: normal 12px Verdana, Calibri, Geneva, sans-serif; color: #000000;">The Dashboard\'s panels, one per row.<br />Mousing over the table highlights the Dashboard\'s panels in the diagram.</p>'
    @@htmlTableFNote = <<-TABLEFNOTE
    <p><span style="font: normal 12px Verdana, Calibri, Geneva, sans-serif; color: #000000;">
       Note: the Dashboard\'s \'x\', \'y\', \'w\', and \'h\' values are shown as coded in the<br />Tableau Workbook.
             It appears that the maximum value &ndash;100,000&ndash; indicates<br />
             that the Dashboard size is set to Automatic, or Range with no upper limit.
       </span>
     </p>
     TABLEFNOTE

    @maxSVGDim    = 600.0  # need the decimal for dashboard scaling with svgScale in fn termDashSVG
    @maxDashWidth = 1.0
    @strokeWidth  = 300
    @@fontSize    = 2000

    @htmlHead      = ''

    @@htmlTableHead = "<table>\n<tr><th align='left'>Zone Name</th><th align='left'>Type</th><th>x</th><th>y</th><th>w</th><th>h</th><th>ID</th></tr>"
    @htmlTable      = ''
    @svgHead        = ''
    @svg            = ''
    @@svgTail       = "</g>\n</svg>"


    @@typeFillColors = {
                    'bitmap'              => 'white',
                    'chart'               => 'white',
                    'Color Legend'        => '#CD853F',
                    'currpage'            => 'white',
                    'draw'                => 'white',
                    'empty'               => 'white',
                    'Blank'               => 'white',
                    'Filter'              => '#228B22',
                    'layout-basic'        => '#B0C4DE',
                    'Layout - Basic'      => '#B0C4DE',
                    'layout-flow'         => '#B0C4DE',
                    'Layout - Flow'       => '#B0C4DE',
                    'Layout - Vertical'   => '#B0C4DE',
                    'Layout - Horizontal' => '#B0C4DE',
                    'Image'               => 'lightgreen',
                    'map'                 => '#CD853F',
                    'map legend'          => '#CD853F',
                    'mru-entry'           => 'white',
                    'paramctrl'           => '#228B22',
                    'Parameter'           => '#228B22',
                    'shape'               => '#CD853F',
                    'Shape Legend'        => '#CD853F',
                    'size'                => '#CD853F',
                    'Size Legend'         => '#CD853F',
                    'Text'                => '#5F9EA0',
                    'text-block'          => '#5F9EA0',
                    'Title'               => '#5F9EA0',
                    'web'                 => 'lightgreen'
                  }
def init
# --
    @jsVars = <<-JSVARS
    var oldFill  = ''
    var oldOpac  = ''
    var oldStroW = ''
    var origLColWidth = "%s"
    var origSvgWidth  = "%s"
    var origSvgHeight = "%s"
    var origSvgScale  = "%s"
    JSVARS

# --
    @fnScaleDash = <<-FNSD
    function scaleDash(){
      var svg  = document.getElementById("svg");
      var lCol = document.getElementById("LeftColumn");

      var sf = document.getElementById("scaleFactor").value;
      var scale = 1;
      var spct  = sf;
      if (isNaN(sf))
         { scale = 1;
           spct  = 100
         }
      else if (sf < 10)
         { scale = .1 ;
           spct  = 10
         }
      else if (sf > 100)
         { scale = 1 ;
           spct  = 100
         }
      else
         { scale = sf / 100 ;
           spct  = sf
         }

      var newLColWidth = (origLColWidth * scale) + 5
      var newSvgWidth  = origSvgWidth  * scale
      var newSvgHeight = origSvgHeight * scale
      var newSvgScale  = origSvgScale  * scale
      var newSvgTransf = "translate(10,10) scale(" + newSvgScale + ")"

      document.getElementById("LeftColumn").setAttribute("width",newLColWidth);
      svg.setAttribute("width", newSvgWidth)
      svg.setAttribute("height",newSvgHeight)
      svg.getElementById("svgTransform").setAttribute("transform",newSvgTransf)

      var newDivWidthPx  = newLColWidth + "px"
      var newDivWidthStr = "display:block;width:" + newDivWidthPx
      document.getElementById('LeftColumn').setAttribute("style",newDivWidthStr);
      document.getElementById('LeftColumn').style.width=newDivWidthPx;

      var r  = document.getElementById("result");
      r.innerHTML = "scale: " + spct + "%" // + document.getElementById("LeftColumn").getAttribute("width")
    }
    FNSD
# --

end


    # Create instance of the Dashboard X-Ray machine.
    # The parameter 'twb' can be either a Twb::Workbook
    # or a String naming the TWB to be X-Rayed.
    def initialize twb
      @workbook = if twb.instance_of?(Twb::Workbook)
                  then twb
                  else Twb::Workbook.new(twb)
                  end
      @dashboards = @workbook.dashboards
      @maxSVGDim  = 600.0
      @svgPadding = 10
      init
    end

    # Performs an analysis of the Workbook's Sashboards akin to an X-Ray imaging.
    # Each of the Dashboards' component parts, "<zone"s in the TWB's xml, is captured.
    # Generates an HTML file that contains a schematic of the zones along with a
    # table that identifes the zones and, when moused over, highlights the zone in
    # the schematic.
    # The active elements in the HTML file are in SVG.
    def xray
      dashCnt = 0
      @dashboardHTMLDocs = {}
      @dashboards.each do |dash|
        @htmldoc    = ''
        @dashNodeDepth = dash.node.ancestors.size   # depth 3 as of Tableau v7
        $maxWidth, $maxHeight = 0, 0
        @svg      = ''
        initDashSVG(dash.name)
        setScale(dash)
        dZones     = dash.node.xpath('.//zone')
        dzcnt      = 0
        @htmlTable = ''
        dZones.each do |zone|
           recordZone(dash.name, zone, dzcnt+=1)
        end
        termDashSVG
        initDashHTML(dash.name, dashCnt += 1, @dashboards.length, dZones.length)
        @dashboardHTMLDocs[dash.name] = termDashHTML(dZones.length)
      end
      return @dashboardHTMLDocs
    end

    def getFillColor type
      fillColor = if type.nil?
        then 'white'
        else @@typeFillColors[type.to_s]
      end
      return fillColor
    end

    def getZoneName zone
        name = zone.attribute('name')
        if   name.nil?
        then name = ''
        end
        zoneDepth    = zone.ancestors.size
        zoneRelDepth = zoneDepth - @dashNodeDepth - 2
        # example TWB structure
        # <dashboards>
        #   <dashboard
        #     <zones>
        #       <zone
        zoneHead  = @@zoneNamePadText * zoneRelDepth
        name = zoneHead + '|' + name
        return name
    end

    def getZoneType(zone)
      type       = zone.attribute('type')
      param      = zone.attribute('param').to_s
      layoutHorz = zone.attribute('layout-horz').to_s
      if type.nil?
        then typeLabel = 'chart'
        else typeLabel = @@typeLabels[type.to_s]
      end
      if typeLabel == 'Layout - Flow' then
         typeLabel = case param
                       when 'vert' then 'Layout - Vertical'
                       when 'horz' then 'Layout - Horizontal'
                       else case layoutHorz
                             when 'true'  then 'Layout - Horizontal'
                             when 'false' then 'Layout - Vertical'
                                          else 'Layout - Flow'
                            end
                     end
      end
      return typeLabel
    end

    def initDashSVG(dashName)
        dashFName = dashName.gsub(/[<>:'"\/\|?*]/,'')
        $Fsvg = File.open("#{@workbook.name}.#{dashFName}.svg",'w')
        $Fsvg.puts('<?xml version="1.0" standalone="no"?>')
        $Fsvg.puts('<!DOCTYPE svg PUBLIC "-//W3C//Dth SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/Dth/svg11.dth">')
        $Fsvg.puts(' ')
    end



    def termDashSVG
        svgScale = @maxSVGDim / @maxDashWidth
        @svgHead  =  "<svg id='svg' width='#{@maxDashWidth*svgScale   + 2*@svgPadding}'\n"
        @svgHead <<  "              height='#{@maxDashHeight*svgScale + 2*@svgPadding}'\n"
        @svgHead <<  "              version='1.1'\n"
        @svgHead <<  "              xmlns='http://www.w3.org/2000/svg'>\n"
        @svgHead <<  "              <g id=\"svgTransform\" transform=\"translate(10,10) scale(#{svgScale})\">"
        $Fsvg.puts @svgHead
        $Fsvg.puts @svg
        $Fsvg.puts @@svgTail
        $Fsvg.close unless $Fsvg.nil?
    end

    def initDashHTML(dashName, dashNum, dashCount, zonesCnt)
        @htmlHead  = '<!DOCTYPE HTML PUBLIC "-//W3C//Dth HTML 3.2 Final//EN">'
        @htmlHead << "\n<HTML>"
        @htmlHead << "\n<HEAD>"

        @htmlHead << "<TITLE>#{dashName}Dashboard Schematic</TITLE>"
        @htmlHead << "\n<META NAME=\"Generator\" CONTENT=\"xraydashboards.rb\">"
        @htmlHead << "\n<META NAME=\"Author\" CONTENT=\"Chris Gerrard\">"
        @htmlHead << "\n<META NAME=\"Copyright\" CONTENT=\"2012, 2015 Chris Gerrard all rights reserved.\">"
        @htmlHead << "\n<META NAME=\"Keywords\" CONTENT=\"xraydashboards.rb TWB Tools\">"
        @htmlHead << "\n<META NAME=\"Description\" CONTENT=\"Creates an interactive diagram of Tableau dashboard components with associated table of values.\">"

        @htmlHead << "\n<style>"

        @htmlHead << "\n#LeftTitle   {font: Verdana, Calibri, Geneva, sans-serif; font-size:1em; float:left; margin: 0 5px 0 0;   vertical-align:top; text-align:left;}"
        @htmlHead << "\n#RightTitle  {font: Verdana, Calibri, Geneva, sans-serif; font-size:1em; float:left; margin: 0 0   0 10px; vertical-align:top;}"
        @htmlHead << "\n#LeftColumn  {font: Verdana, Calibri, Geneva, sans-serif; font-size:1em; float:left; margin: 0 5px 0 0;   vertical-align:top; text-align:left;}"
        @htmlHead << "\n#RightColumn {font: Verdana, Calibri, Geneva, sans-serif; font-size:1em; float:left; margin: 0 0   0 10px; vertical-align:top;}"

        @htmlHead << "\ntable              { font-family: Verdana, Calibri, Geneva, sans-serif; font-size:.9em; border-collapse:collapse;padding:5 15 5 10; text-align:right;}"
        @htmlHead << "\ntable td, table th { font-family: Verdana, Calibri, Geneva, sans-serif; font-size:.9em; border:3px solid #B0C4DE; padding:0 0 0 0; }"
        @htmlHead << "\ntable th           { font-family: Verdana, Calibri, Geneva, sans-serif; font-size:.9em; font-size:.8em; background-color:lightgrey; color:black; }"
        @htmlHead << "\ntable tr.alt td    { font-family: Verdana, Calibri, Geneva, sans-serif; font-size:.9em; border:1px solid #B0C4DE; color:#000; background-color:#EAF2D3; }"

        @htmlHead << "\n</style>"
        @htmlHead << "\n<script>\n"
        @htmlHead << @jsVars % [@maxSVGDim, @maxDashWidth, @maxDashHeight, @maxSVGDim/@maxDashWidth]
        @htmlHead << "\nfunction highlightDashComponent(id)"
        @htmlHead << "\n{"
        @htmlHead << "\n  element =  document.getElementById(id)"
        @htmlHead << "\n  oldFill = element.getAttribute('fill')"
        @htmlHead << "\n  oldOpac = element.getAttribute('opacity')"
        @htmlHead << "\n  oldStroW = element.getAttribute('stroke-width')"
        @htmlHead << "\n  element.setAttribute('fill','darkgrey')"
        @htmlHead << "\n  element.setAttribute('opacity','1')"
        @htmlHead << "\n  element.setAttribute('stroke-width','800')"
        @htmlHead << "\n  // alert(id + ' HIGH fill: ' + oldFill)"
        @htmlHead << "\n}"
        @htmlHead << "\nfunction resetDashComponent(id)"
        @htmlHead << "\n{"
        @htmlHead << "\n  element =  document.getElementById(id)"
        @htmlHead << "\n  element.setAttribute('fill',oldFill)"
        @htmlHead << "\n  element.setAttribute('opacity',oldOpac)"
        @htmlHead << "\n  element.setAttribute('stroke-width',oldStroW)"
        @htmlHead << "\n}\n"
        @htmlHead << @fnScaleDash
        @htmlHead << "\n</script>"
        @htmlHead << "\n</HEAD>"
        @htmlHead << "\n<BODY BGCOLOR=\"#FFFFFF\">\n"
        if zonesCnt > 0
          addPageLead(dashName, dashNum, dashCount)
        else
          @htmlHead << "\n<div style='font-size:125%; margin: 25px 0 0 5em;'>'#{dashName}' has no panels (zones)</div>"
        end
    end

    def addPageLead(dashName, dashNum, dashCount)
        @htmlHead << <<-PAGELEAD
    <div id='LeftTitle' width='45%'>
        <p><span style='font: normal 16px Verdana, Calibri, Geneva, sans-serif; color: #000000;padding: 0px 10px 0px 15px;'>#{@workbook.name}</span><br />
           <span style='font: normal 12px Verdana, Calibri, Geneva, sans-serif; color: #000000;padding: 10px 10px 0px 15px;'>Dashboard: \"#{dashName}\" \##{dashNum} of #{dashCount} </span></p>
    </div>
    <div id='RightTitle' width='45%'>
        <p><span style='font: normal 12px Verdana, Calibri, Geneva, sans-serif; color: #351c75;padding: 10px 10px 0px 15px;'>
           Resize the Dashboard, from 10-100% :
           </span>
        <input id='scaleFactor' type='range' min='10' max='100' value='100' step='5' onChange='scaleDash();'> <span id='result' style='font: normal 12px Verdana, Calibri, Geneva, sans-serif; color: #351c75;padding: 10px 10px 0px 15px;'>scale: 100%</span>
        </p>
    </div>
    <div style='clear:both;'></div>
    PAGELEAD
    end


    def termDashHTML(zonesCnt)
        dhtml = ''
        dhtml <<  @htmlHead
        if zonesCnt > 0
          dhtml <<  '<div id="LeftColumn" width="620">'
          dhtml <<  @svgHead
          dhtml <<  @svg
          dhtml <<  @@svgTail
          dhtml <<  '</div>'
          dhtml <<  '<div id="RightColumn">'
          dhtml <<  @@htmlTableLead
          dhtml <<  @@htmlTableHead
          dhtml <<  @htmlTable
          dhtml << ('</table>')
          dhtml <<  @@htmlTableFNote
          dhtml <<  '</div>'
        end
        dhtml << ('</BODY>')
        dhtml << ('</HTML>')
    end

    def setScale dashboard
      dashSize    = dashboard.node.xpath('./size')
      @maxDashWidth  = 0
      @maxDashHeight = 0
      if dashSize.nil?
      then
        $maxWidth  = 0
        $maxHeight = 0
      else
        sizeNode = dashSize.first
        if sizeNode.nil?
        then
          $maxWidth  = 0
           $maxHeight = 0
        else
           $maxWidth  = if sizeNode.attribute('maxwidth').nil?  then 1000.0 else sizeNode.attribute('maxwidth').text.to_f end
           $maxHeight = if sizeNode.attribute('maxheight').nil? then 1000.0 else sizeNode.attribute('maxheight').text.to_f end
        end
      end
    end

    def recordZone(dashName, zone, thcnt)
          id        =  "#{zone.attribute('id')}-:-#{thcnt}"
          zoneName  = getZoneName zone
          type      = getZoneType(zone)
          fillColor = getFillColor(type)
          fill      = "fill=\"#{fillColor}\";"
          @svg += "\n<g>"
          rxy = ' rx="3000" ry="3000"'
          drawLine = ''
          if type.start_with?('Layout') then
             @strokeWidth = 500
             strokeStyle  = 'stroke:black;stroke-linecap:round;stroke-linejoin:miter;stroke-miterlimit:4;stroke-opacity:1;stroke-dasharray:1200, 1200;stroke-dashoffset:0;'
             x  = zone.attribute('x').text.to_i + @strokeWidth
             y  = zone.attribute('y').text.to_i + @strokeWidth
             w  = zone.attribute('w').text.to_i
             h  = zone.attribute('h').text.to_i
             rxy = ''
             drawLine = if /.*ertical.*/ =~ type then 'vert' else 'horz' end
             # ecx = x+w/2
             # erx = w/2
             # ecy = y+h/2
             # ery = h/2
             # @svg += "\n<ellipse cx=\"#{ecx}\" cy=\"#{ecy}\" rx=\"#{erx}\" ry=\"#{ery}\" style=\"stroke:darkblue;fill:blue;\"/>"
          else
             drawLine = ''
             rxy = ' rx="3000" ry="3000"'
             @strokeWidth = 200
             strokeStyle    = 'stroke:blue;'
             x  = zone.attribute('x').text.to_i + @strokeWidth
             y  = zone.attribute('y').text.to_i + @strokeWidth
             w  = zone.attribute('w').text.to_i
             h  = zone.attribute('h').text.to_i
          end
          cw = x+w
          ch = y+h
          @maxDashWidth  = [@maxDashWidth,  cw].max
          @maxDashHeight = [@maxDashHeight, ch].max
          @svg += "\n<rect"
          @svg += " id=\"#{id}-:-#{thcnt}\""
          @svg += " width=\"#{w}\""
          @svg += " height=\"#{h}\""
          @svg += " x=\"#{x}\""
          @svg += " y=\"#{y}\""
          @svg += rxy
          @svg += " fill=\"#{fillColor}\""
          @svg += " opacity=\"0.2\""
          @svg += " stroke-width=\"#{@strokeWidth}\""
          @svg += " style=\"color:#000000;#{strokeStyle}stroke-opacity:1;\" />"
          @svg += "\n"
          case drawLine
            when 'vert' then @svg += "\n<line    x1=\"#{x}\"   y1=\"#{y}\"   x2=\"#{x+w}\" y2=\"#{y+h}\" style=\"stroke:grey;stroke-width:100\"/>"
            when 'horz' then @svg += "\n<line    x1=\"#{x}\"   y1=\"#{y+h}\" x2=\"#{x+w}\" y2=\"#{y}\"   style=\"stroke:grey;stroke-width:100\"/>"
          end
          case type.downcase
                 when 'color legend' then addColorLegend(x,y,w,h)
                 when 'filter'       then addFilterLegend(x,y,w,h)
                 when 'chart'        then addChartLegend(x,y,w,h)
                 when 'image'        then addImageLegend(x,y,w,h)
                 when 'empty',
                      'blank'        then addLabel(x,y,w,h,'[ ]')
                 when 'paramctrl',
                      'parameter'    then addLabel(x,y,w,h,'>...<')
                 when 'size',
                      'size legend'  then addSizeLegend(x,y,w,h)
                 when 'shape',
                      'shape legend' then addShapeLegend(x,y,w,h)
                 when 'text'         then addLabel(x,y,w,h,'loren ipsum')
                                   # else addLabel(x,y,w,h, "#{type} id: #{id}")
          end
          @svg += "\n</g>\n"
          @htmlTable += "\n<tr style=\"cursor: pointer;\" onMouseOver=\"highlightDashComponent('#{id}-:-#{thcnt}')\" onMouseOut=\"resetDashComponent('#{id}-:-#{thcnt}')\">"
          @htmlTable += "    <td style='text-align: left;'>#{zoneName}</td>"
          @htmlTable += "    <td style='text-align: left;'>#{type}</td>"
          @htmlTable += "    <td>#{x.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse}</td>"
          @htmlTable += "    <td>#{y.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse}</td>"
          @htmlTable += "    <td>#{w.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse}</td>"
          @htmlTable += "    <td>#{h.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse}</td>"
          @htmlTable += "    <td>#{id.gsub('-:-','.')}.#{thcnt}</td>"
          @htmlTable += "</tr>"
          return @htmlTable
    end # def recordZone

    def addLabel(x,y,w,h,type)
      tw  = type.length * @@fontSize
      centerX = x + w/2
      centerY = y + h/2
      transform = if tw > w*1.2 then " transform=\"rotate(-90 #{centerX} #{centerY})\"" else '' end
      twh = tw/4
      tx  = x + w/2   - twh
      ty  = y + (h/2) + 500
      @svg += "<text x=\"#{tx}\" y=\"#{ty}\" font-size=\"#{@@fontSize}\" font-family=\"Verdana,Arial\"#{transform}>#{type}</text>"
    end

    def addFilterLegend(x,y,w,h)
      lx = x + w/2 - @@fontSize
      ly = y + h/2 + @@fontSize/2
      @svg += "<text x=\"#{lx}\" y=\"#{ly}\""
      @svg += ' id="FilterYes"'
      @svg += " font-size=\"#{@@fontSize}\""
      @svg += ' font-family="Verdana,Arial">'
      @svg += "&#x2713; X</text>"
    end

    def addChartLegend(x,y,w,h)
        barHeight = h/4
        barWidth  = [w/20, barHeight/5].min
        bx = x + (w/2) -  barWidth
        by = y + (h/2) - (barHeight/2)
        @svg += "\n<rect x=\"#{bx}\"                 y=\"#{by}\"             width=\"#{barWidth}\" height=\"#{barHeight}\"   fill=\"blue\"    stroke-width=\"200\" stroke=\"black\"/>"
        @svg += "\n<rect x=\"#{bx + 1.5*barWidth}\"  y=\"#{by+barHeight/2}\" width=\"#{barWidth}\" height=\"#{barHeight/2}\" fill=\"orange\"  stroke-width=\"100\" stroke=\"black\"/>"
        @svg += "\n"
    end

    def addImageLegend(x,y,w,h)
        cameraW = @@shapeRadius * 5
        cameraH = @@shapeRadius * 3
        cx = x + w/2 - cameraW/2
        cy = y + h/2
        lx = cx + @@shapeDiam
        ly = cy + cameraH/2
        vw = cameraW / 5
        vh = cameraH / 5
        vx = cx + cameraW - vw*1.5
        vy = cy + vh
        @svg += "\n<rect    x=\"#{cx}\"  y=\"#{cy}\" width=\"#{cameraW}\" height=\"#{cameraH}\" fill=\"lightgrey\" stroke-width=\"200\" stroke=\"black\" opacity=\"1\"/>"
        @svg += "\n<rect    x=\"#{vx}\"  y=\"#{vy}\" width=\"#{vw}\"      height=\"#{vh}\"      fill=\"lightgrey\" stroke-width=\"200\" stroke=\"black\" opacity=\"1\"/>"
        @svg += "\n<circle cx=\"#{lx}\" cy=\"#{ly}\"     r=\"#{@@shapeRadius*0.8}\"              fill=\"lightgrey\" stroke-width=\"200\" stroke=\"black\" opacity=\"1\"/>"
        @svg += "\n"
    end

    def addColorLegend(x,y,w,h)
        d  = @@shapeDiam
        cx = x + w/2
        cy = y + h/2
        sx = cx - (2 * d)
        sy = cy - (d / 2)
        @svg += "\n<rect x=\"#{sx}\"          y=\"#{sy}\" width=\"#{d}\" height=\"#{d}\" fill=\"blue\"  stroke-width=\"none\" stroke=\"none\" opacity=\"1\"/>"
        @svg += "\n<rect x=\"#{sx + 1.5*d}\"  y=\"#{sy}\" width=\"#{d}\" height=\"#{d}\" fill=\"red\"   stroke-width=\"none\" stroke=\"none\" opacity=\"1\"/>"
        @svg += "\n<rect x=\"#{sx +   3*d}\"  y=\"#{sy}\" width=\"#{d}\" height=\"#{d}\" fill=\"green\" stroke-width=\"none\" stroke=\"none\" opacity=\"1\"/>"
        @svg += "\n"
    end

    def addShapeLegend(x,y,w,h)
        centerX     = x + w/2
        centerY     = y + h/2
        cx = centerX - 3*@@shapeRadius
        cy = centerY + @@shapeRadius/2
        rx = centerX - @@shapeRadius
        ry = centerY - @@shapeRadius/2
        tx = centerX + @@shapeDiam
        ty = centerY - @@shapeRadius/2
        @svg += "\n<circle       cx=\"#{cx}\" cy=\"#{cy}\"        r=\"#{@@shapeRadius}\"                          fill=\"#008080\" stroke-width=\"200\" stroke=\"black\" opacity=\"0.8\"/>"
        @svg += "\n<rect          x=\"#{rx}\"  y=\"#{ry}\"    width=\"#{@@shapeDiam}\"   height=\"#{@@shapeDiam}\" fill=\"#008080\" stroke-width=\"200\" stroke=\"black\" opacity=\"0.8\"/>"
        @svg += "\n<polyline points=\"#{tx}             ,#{ty+@@shapeDiam}
                                      #{tx+@@shapeDiam}  ,#{ty+@@shapeDiam}
                                      #{tx+@@shapeRadius},#{ty}
                                      #{tx}             ,#{ty+@@shapeDiam}\" fill=\"#008080\" stroke-width=\"200\" stroke=\"black\" opacity=\"0.8\"/>"
    end

    def addSizeLegend(x,y,w,h)
        centerX     = x + w/2
        centerY     = y + h/2
        smallRadius = @@shapeRadius/2
        medRadius   = @@shapeRadius
        largeRadius = smallRadius + medRadius
        sx = centerX - medRadius*3
        mx = centerX - medRadius
        lx = centerX + medRadius*2
        @svg += "\n<circle cx=\"#{sx}\" cy=\"#{centerY}\" r=\"#{smallRadius}\"  fill=\"#008080\" stroke-width=\"200\" stroke=\"black\" opacity=\"0.8\"/>"
        @svg += "\n<circle cx=\"#{mx}\" cy=\"#{centerY}\" r=\"#{medRadius}\"    fill=\"#008080\" stroke-width=\"200\" stroke=\"black\" opacity=\"0.8\"/>"
        @svg += "\n<circle cx=\"#{lx}\" cy=\"#{centerY}\" r=\"#{largeRadius}\"  fill=\"#008080\" stroke-width=\"200\" stroke=\"black\" opacity=\"0.8\"/>"
    end

  end
  
end  