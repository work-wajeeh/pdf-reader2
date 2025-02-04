# coding: utf-8
# typed: strict
# frozen_string_literal: true

################################################################################
#
# Copyright (C) 2006 Peter J Jones (pjones@pmade.com)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################

class Pdf::Reader2
  ################################################################################
  # Various parts of a Pdf file can be passed through a filter before being stored to provide
  # support for features like compression and encryption. This class is for decoding that
  # content.
  #
  module Filter # :nodoc:

    ################################################################################
    # creates a new filter for decoding content.
    #
    # Filters that are only used to encode image data are accepted, but the data is
    # returned untouched. At this stage Pdf::Reader2 has no need to decode images.
    #
    def self.with(name, options = {})
      case name
      when :ASCII85Decode, :A85   then Pdf::Reader2::Filter::Ascii85.new(options)
      when :ASCIIHexDecode, :AHx  then Pdf::Reader2::Filter::AsciiHex.new(options)
      when :CCITTFaxDecode, :CCF  then Pdf::Reader2::Filter::Null.new(options)
      when :DCTDecode, :DCT       then Pdf::Reader2::Filter::Null.new(options)
      when :FlateDecode, :Fl      then Pdf::Reader2::Filter::Flate.new(options)
      when :JBIG2Decode           then Pdf::Reader2::Filter::Null.new(options)
      when :JPXDecode             then Pdf::Reader2::Filter::Null.new(options)
      when :LZWDecode, :LZW       then Pdf::Reader2::Filter::Lzw.new(options)
      when :RunLengthDecode, :RL  then Pdf::Reader2::Filter::RunLength.new(options)
      else
        raise UnsupportedFeatureError, "Unknown filter: #{name}"
      end
    end
  end
end
