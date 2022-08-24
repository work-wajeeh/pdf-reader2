# typed: true
# coding: utf-8

module ParserHelper
  def parse_string(r)
    buf = PDF::Reader2::Buffer.new(StringIO.new(r))
    PDF::Reader2::Parser.new(buf, nil)
  end
end
