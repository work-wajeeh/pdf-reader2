# typed: true
# coding: utf-8

module ParserHelper
  def parse_string(r)
    buf = Pdf2::Reader2::Buffer.new(StringIO.new(r))
    Pdf2::Reader2::Parser.new(buf, nil)
  end
end
