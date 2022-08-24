# typed: false
# coding: utf-8

describe PDF2::Reader2::LZW do
  describe "#decode" do
    it "decodes a lzw compress string" do
      content = %w{ 80 0B 60 50 22 0C 0C 85 01 }.map { |byte|
        byte.to_i(16)
      }.pack("C*")

      expect(PDF2::Reader2::LZW.decode(content)).to eq('-----A---B')
    end

    it "decodes another lzw compressed string" do
      content = binread(File.dirname(__FILE__) + "/data/lzw_compressed2.dat")

      expect(PDF2::Reader2::LZW.decode(content)).to match(/\ABT/)
    end

    it "raises PDF2::Reader2::MalformedPDFError when the stream isn't valid lzw" do
      content = binread(File.dirname(__FILE__) + "/data/lzw_compressed_corrupt.dat")

      expect {
        PDF2::Reader2::LZW.decode(content)
      }.to raise_error(PDF2::Reader2::MalformedPDFError)
    end
  end
end
