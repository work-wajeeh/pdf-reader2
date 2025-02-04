# coding: utf-8
# typed: strict
# frozen_string_literal: true

class Pdf::Reader2
  module WidthCalculator
    # CIDFontType0 or CIDFontType2 use DW (integer) and W (array) to determine
    # codepoint widths, note that CIDFontType2 will contain a true type font
    # program which could be used to calculate width, however, a conforming writer
    # is supposed to convert the widths for the codepoints used into the W array
    # so that it can be used.
    # see Section 9.7.4.1, Pdf 32000-1:2008, pp 269-270
    class Composite

      def initialize(font)
        @font = font
        @widths = Pdf::Reader2::CidWidths.new(@font.cid_default_width, @font.cid_widths)
      end

      def glyph_width(code_point)
        return 0 if code_point.nil? || code_point < 0

        w = @widths[code_point]
        # 0 is a valid width
        if w
          w.to_f
        else
          0
        end
      end
    end
  end
end
