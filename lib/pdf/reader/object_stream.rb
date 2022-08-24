# coding: utf-8
# typed: strict
# frozen_string_literal: true

class PDF::Reader2

  # provides a wrapper around a PDF stream object that contains other objects in it.
  # This is done for added compression and is described as an "Object Stream" in the spec.
  #
  class ObjectStream # :nodoc:
    def initialize(stream)
      @dict = stream.hash
      @data = stream.unfiltered_data
    end

    def [](objid)
      if offsets[objid].nil?
        nil
      else
        buf = PDF::Reader2::Buffer.new(StringIO.new(@data), :seek => offsets[objid])
        parser = PDF::Reader2::Parser.new(buf)
        parser.parse_token
      end
    end

    def size
      TypeCheck.cast_to_int!(@dict[:N])
    end

    private

    def offsets
      @offsets ||= {}
      return @offsets if @offsets.keys.size > 0

      size.times do
        @offsets[buffer.token.to_i] = first + buffer.token.to_i
      end
      @offsets
    end

    def first
      TypeCheck.cast_to_int!(@dict[:First])
    end

    def buffer
      @buffer ||= PDF::Reader2::Buffer.new(StringIO.new(@data))
    end

  end

end

