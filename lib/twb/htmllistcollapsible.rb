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

  class HTMLListCollapsible

    @@doc = Nokogiri::HTML::Document.parse  <<-COLLAPSIBLELIST
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    <head>
        <title>Tableau Documentation</title>
    
        <style type="text/css">
            body, a {
                color: #3B4C56;
                font-family: sans-serif;
                font-size: 14px;
                text-decoration: none;
            }
            #pgtitle
            {
               margin: 0px 0px 20px;
               font-size: 14pt;
               text-align: center;
            }
            a{
               cursor:pointer;
            }
            .tree ul {
                list-style: none outside none;
            }
            .tree li a {
                line-height: 25px;
            }
            .tree > ul > li > a {
                color: #3B4C56;
                display: block;
                font-weight: normal;
                position: relative;
                text-decoration: none;
            }
            .tree li.parent > a {
                padding: 0 0 0 28px;
            }
            .tree li.parent > a:before {
                background-image: url("Controls.png");
                background-position: 20px center;
                 content: "";
                display: block;
                height: 20px;
                left: 0;
                position: absolute;
                top: 2px;
                vertical-align: middle;
                width: 20px;
            }
            .tree ul li.active > a:before {
                background-position: 0 center;
            }
            .tree ul li ul {
                border-left: 1px solid #D9DADB;
                display: none;
                margin: 0 0 0 12px;
                overflow: hidden;
                padding: 0 0 0 25px;
            }
            .tree ul li ul li {
                position: relative;
            }
            .tree ul li ul li:before {
                border-bottom: 1px dashed #E2E2E3;
                content: "";
                left: -20px;
                position: absolute;
                top: 12px;
                width: 15px;
            }
            #wrapper {
                margin: 0 auto;
                width: 300px;
            }
        </style>
    
        <script src="http://code.jquery.com/jquery-1.7.2.min.js" type="text/javascript" > </script>
    
        <script type="text/javascript">
            $( document ).ready( function( ) {
                    $( '.tree li' ).each( function() {
                            if( $( this ).children( 'ul' ).length > 0 ) {
                                    $( this ).addClass( 'parent' );
                            }
                    });
    
                    $( '.tree li.parent > a' ).click( function( ) {
                            $( this ).parent().toggleClass( 'active' );
                            $( this ).parent().children( 'ul' ).slideToggle( 'fast' );
                    });
    
                    $( '#all' ).click( function() {
    
                        $( '.tree li' ).each( function() {
                            $( this ).toggleClass( 'active' );
                            $( this ).children( 'ul' ).slideToggle( 'fast' );
                        });
                    });
    
                    $( '.tree li' ).each( function() {
                            $( this ).toggleClass( 'active' );
                            $( this ).children( 'ul' ).slideToggle( 'fast' );
                    });
    
            });
    
        </script>
    
    </head>
    <body>
        <div id="pgtitle">
            Expandable nested list.
        </div>
        <div id="wrapper">
        <div class="tree">
        <button id="all">Toggle all</button>
        <ul>
        </ul>
        </div>
        </div>
    
    </body>
    </html>
    COLLAPSIBLELIST
    
    def html
     " here's the @@doc"
    end

  end

end