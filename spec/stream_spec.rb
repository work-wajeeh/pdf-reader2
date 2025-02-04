# typed: false
# coding: utf-8

describe Pdf::Reader2::Stream do
  include EncodingHelper

  it "decodes streams that use FlateDecode" do
    decoded_stream = "\n0.000 0.000 0.000 rg\n0.000 0.000 0.000 RG\nq\n1 w\nQ\nq\n1 w\nQ\nq\nq\n430.000 0 0 787.000 300.000 50.000 cm\n/I0 Do\nQ\nq\n1.000 0.000 0.000 rg\n1.000 0.000 0.000 RG\n72.000 0.000 81.156 792.000 re f\n1.000 1.000 1.000 rg\n1.000 1.000 1.000 RG\nBT 0.000 1.000 -1.000 0.000 137.303 70.000 Tm /F1 72.0 Tf 0 Tr (Pdf::Writer for Ruby) Tj ET\n1 w\nQ\nBT 536.664 711.216 Td /F1 24.0 Tf 0 Tr (\n) Tj ET\nBT 170.016 684.432 Td /F1 24.0 Tf 0 Tr (Native Ruby Pdf Document Creation\n) Tj ET\nBT 540.220 662.112 Td /F1 20.0 Tf 0 Tr (\n) Tj ET\nBT 357.440 639.792 Td /F1 20.0 Tf 0 Tr (The Ruby Pdf Project\n) Tj ET\nBT 237.480 617.472 Td ET\nq\n0.000 0.000 1.000 rg\n0.000 0.000 1.000 RG\n1.116 w [ ] 0 d\nBT 237.480 617.472 Td 0.000 Tw /F1 20.0 Tf 0 Tr (http://rubyforge.org/projects/ruby-pdf) Tj ET\n237.480 615.798 m\n540.220 615.798 l S\n1 w\nQ\nBT 540.220 617.472 Td /F1 20.0 Tf 0 Tr (\n) Tj ET\nBT 436.340 595.152 Td 0.000 Tw /F1 20.0 Tf 0 Tr (version 1.1.2\n) Tj ET\nBT 541.998 575.064 Td 0.000 Tw /F1 18.0 Tf 0 Tr (\n) Tj ET\nBT 368.748 554.976 Td 0.000 Tw /F1 18.0 Tf 0 Tr (Copyright \251 2003\2262005\n) Tj ET\nBT 437.508 534.888 Td 0.000 Tw ET\nq\n0.000 0.000 1.000 rg\n0.000 0.000 1.000 RG\n1.0044 w [ ] 0 d\nBT 437.508 534.888 Td /F1 18.0 Tf 0 Tr (Austin Ziegler) Tj ET\n437.508 533.381 m\n541.998 533.381 l S\n1 w\nQ\nBT 541.998 534.888 Td /F1 18.0 Tf 0 Tr (\n) Tj ET\n1 w\nQ"

    io    = File.new(pdf_spec_file("pdfwriter-manual"))
    ohash = Pdf::Reader2::ObjectHash.new(io)
    obj   = ohash.object(Pdf::Reader2::Reference.new(7, 0))
    expect(obj).to be_a_kind_of(Pdf::Reader2::Stream)
    expect(obj.unfiltered_data).to eql(binary_string(decoded_stream))
  end

  context "with a zlib stream (RFC1950) that fails an adler32 CRC check" do
    let(:decoded_stream) { <<EOF
/CIDInit /ProcSet findresource begin
12 dict begin
begincmap
/CIDSystemInfo <</Registry (F1+0) /Supplement 0 >> def
/CMapName /F1+0 def
/CMapType 2 def
1 begincodespacerange <41><7A> endcodespacerange
52 beginbfchar
<41><0056>
<42><0065>
<43><0072>
<44><00F6>
<45><0066>
<46><006E>
<47><0074>
<48><006C>
<49><0069>
<4A><0063>
<4B><0068>
<4C><0075>
<4D><0067>
<4E><0020>
<4F><0044>
<50><006F>
<51><0027>
<52><0073>
<53><0061>
<54><0032>
<55><0030>
<56><0038>
<57><0053>
<58><0064>
<59><003A>
<5A><0031>
<61><002E>
<62><0033>
<63><004E>
<64><006D>
<65><0070>
<66><0050>
<67><0047>
<68><00FC>
<69><004D>
<6A><006A>
<6B><002C>
<6C><00E4>
<6D><0045>
<6E><004B>
<6F><006B>
<70><0046>
<71><007A>
<72><0049>
<73><0041>
<74><0062>
<75><002F>
<76><0042>
<77><0077>
<78><0054>
<79><0037>
<7A><0036>
endbfchar
endcmap
CMapName currentdict /CMap defineresource pop
end
end
EOF
    }

    context "with a zlib stream that has a single trailing garbage byte" do
      it "makes an effort to decode the stream anyway" do
        File.open(pdf_spec_file("zlib_stream_issue"), "rb") do |io|
          ohash = Pdf::Reader2::ObjectHash.new(io)
          ref   = Pdf::Reader2::Reference.new(30,0)
          obj   = ohash.object(ref)

          expect(obj).to be_a_kind_of(Pdf::Reader2::Stream)
          expect(obj.unfiltered_data).to eql(decoded_stream.strip)
        end
      end
    end
  end
end
