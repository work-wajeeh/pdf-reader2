# coding: utf-8
# typed: strict
# frozen_string_literal: true

class Pdf::Reader2
  module WidthCalculator
    # Calculates the width of a glyph in a Type One or Type Three
    class TypeOneOrThree

      def initialize(font)
        @font = font

        if fd = @font.font_descriptor
          @missing_width = fd.missing_width
        else
          @missing_width = 0
        end
      end

      def glyph_width(code_point)
        return 0 if code_point.nil? || code_point < 0
        return 0 if @font.widths.nil? || @font.widths.count == 0

        # in ruby a negative index is valid, and will go from the end of the array
        # which is undesireable in this case.
        first_char = @font.first_char
        if first_char && first_char <= code_point
          @font.widths.fetch(code_point - first_char, @missing_width.to_i).to_f
        else
          @missing_width.to_f
        end
      end
    end
  end
end
