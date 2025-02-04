# coding: utf-8
# typed: strict
# frozen_string_literal: true

class Pdf::Reader2
  module Filter # :nodoc:
    # implementation of the null stream filter
    class Null
      def initialize(options = {})
        @options = options
      end

      def filter(data)
        data
      end
    end
  end
end
