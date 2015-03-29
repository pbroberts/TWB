A number of Ruby scripts that parse Workbooks and emit a variety of their contents/properties have been published at Tableau Friction, including a couple that identify Calculated fields and the fields they reference:
http://tableaufriction.blogspot.ca/2015/02/more-calculated-field-analysis-fields.html
http://tableaufriction.blogspot.ca/2014/09/do-you-know-what-your-calculated-fields.html

Other scripts find and record other useful information, others yet enable Workbook management, e.g. unhiding worksheets and making field comments consistent across workbook. One of them produces HTML pages with dynamic dashboard wire frames, making it easy to see what's in the dashboards and their properties 

There's also TWIS - the Tableau Workbook Inventory System, an app that extracts into CSV files most of the important Workbook elements, allowing one to see things such as which sheets are in which with dashboards, the data sources they connect to, and which Workbooks they're in. TWIS also generates diagrams/maps of the Workbook - Dashboard - Worksheet - Data Source relationships, one for each Workbook in PDF, PNG, and SVG.
TWIS is described and available here: http://betterbi.biz/TWIS.html

I created TWIS in Java and am working to re-implement its functionality in Ruby with the intention of releasing it as a open source project. The initial Ruby Gem - "twb" - is already available on http://rubygems.org - and can be downloaded and used via "gem install twb". At this point it only represents Workbooks and Data Sources, but I'll be extending it pretty regularly and posting updates to Tableau Friction. Anyone who's interested can comment here or there.

The basic philosophy I'm following is that Tableau Workbook governance should be simple and straightforward in the way that basic data analysis is simple and straightforward in Tableau, and that the tools for it should be free, as in beer and speech, and constantly evolving to incorporate new and interesting things people can think of to see about do with their Workbooks.