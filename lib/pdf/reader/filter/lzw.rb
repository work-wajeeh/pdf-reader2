# coding: utf-8
# typed: strict
# frozen_string_literal: true

#
class Pdf::Reader2
  module Filter # :nodoc:
    # implementation of the LZW stream filter
    class Lzw

      def initialize(options = {})
        @options = options
      end

      ################################################################################
      # Decode the specified data with the LZW compression algorithm
      def filter(data)
        data = Pdf::Reader2::LZW.decode(data)
        Depredict.new(@options).filter(data)
      end
    end
  end
end
