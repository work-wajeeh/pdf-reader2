# typed: true
# coding: utf-8

module BufferHelper
  def parse_string(r)
    Pdf::Reader2::Buffer.new(StringIO.new(r))
  end
end
