# typed: false
# coding: utf-8

describe PDF::Reader2::Filter do

  describe "#with" do
    context "when passed :ASCII85Decode" do
      it "returns the appropriate class" do
        expect(PDF::Reader2::Filter.with(:ASCII85Decode)).to be_a(PDF::Reader2::Filter::Ascii85)
      end
    end

    context "when passed :ASCIIHexDecode" do
      it "returns the appropriate class" do
        expect(PDF::Reader2::Filter.with(:ASCIIHexDecode)).to be_a(PDF::Reader2::Filter::AsciiHex)
      end
    end

    context "when passed :CCITTFaxDecode" do
      it "returns the appropriate class" do
        expect(PDF::Reader2::Filter.with(:CCITTFaxDecode)).to be_a(PDF::Reader2::Filter::Null)
      end
    end

    context "when passed :DCTDecode" do
      it "returns the appropriate class" do
        expect(PDF::Reader2::Filter.with(:DCTDecode)).to be_a(PDF::Reader2::Filter::Null)
      end
    end

    context "when passed :ASCII85Decode" do
      it "returns the appropriate class" do
        expect(PDF::Reader2::Filter.with(:ASCII85Decode)).to be_a(PDF::Reader2::Filter::Ascii85)
      end
    end

    context "when passed :FlateDecode" do
      it "returns the appropriate class" do
        expect(PDF::Reader2::Filter.with(:FlateDecode)).to be_a(PDF::Reader2::Filter::Flate)
      end
    end

    context "when passed :JBIG2ecode" do
      it "returns the appropriate class" do
        expect(PDF::Reader2::Filter.with(:JBIG2Decode)).to be_a(PDF::Reader2::Filter::Null)
      end
    end

    context "when passed :JPXDecode" do
      it "returns the appropriate class" do
        expect(PDF::Reader2::Filter.with(:JPXDecode)).to be_a(PDF::Reader2::Filter::Null)
      end
    end

    context "when passed :LZWDecode" do
      it "returns the appropriate class" do
        expect(PDF::Reader2::Filter.with(:LZWDecode)).to be_a(PDF::Reader2::Filter::Lzw)
      end
    end

    context "when passed :RunLengthDecode" do
      it "returns the appropriate class" do
        expect(PDF::Reader2::Filter.with(:RunLengthDecode)).to be_a(PDF::Reader2::Filter::RunLength)
      end
    end

    context "when passed an unrecognised filter" do
      it "raises an exception" do
        expect {
          PDF::Reader2::Filter.with(:FooDecode)
        }.to raise_error(PDF::Reader2::UnsupportedFeatureError)
      end
    end
  end
end
