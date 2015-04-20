require 'twb'
require "test/unit"

system "cls"

class TestHTMLList < Test::Unit::TestCase
 
  def test_create
    struct = {'a' => {'eh?'=>nil},
            'b' => ['bee', 'be'],
            'empty array' => [],
            'nil value' => [],
            'c' => {'sea'=>['ocean','mer'],
                    'see'=>['vision','sight','lookers']
                   },
            'red' => {'red'=>{'crimson'=>['color','of','blood']},
                      'read'=>['tense uncertain']
                     }
           }
    doc = Twb::HTMLListCollapsible.new(struct)
    doc.title="Important Stuff to See"
    doc.write('test.html')
  end
 
end