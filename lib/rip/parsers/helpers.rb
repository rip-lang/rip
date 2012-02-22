require 'parslet'

require 'rip'

module Rip::Parsers
  module Helpers
    include Parslet

    rule(:whitespace) { space | eol }
    rule(:whitespaces) { whitespace.repeat(1) }
    rule(:whitespaces?) { whitespaces.maybe }

    rule(:space) { str(' ') | str("\t") }
    rule(:spaces) { space.repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:eol) { str("\r\n") | str("\n") | str("\r") }
    rule(:eols) { eol.repeat }

    #---------------------------------------------

    def block(body = statements)
      surround_with('{', body.as(:body), '}')
    end

    # NOTE see "Repetition and its Special Cases" note about #maybe versus #repeat(0, nil) at http://kschiess.github.com/parslet/parser.html
    def thing_list(thing, separator)
      (thing >> (whitespaces? >> (separator.is_a?(String) ? str(separator) : separator) >> whitespaces? >> thing).repeat).repeat(0, nil)
    end

    def surround_with(left, center, right = left)
      str(left) >> whitespaces? >> center >> whitespaces? >> str(right)
    end
  end
end
