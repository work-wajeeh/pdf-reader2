# typed: false
# coding: utf-8

# A set of integration specs that assert we raise expected errors when trying to parse Pdfs that
# are invalid. Usually they have some form of corruption that we're unable to compensate for

describe Pdf::Reader2, "integration specs with invalid Pdf files" do

  context "Empty file" do
    it "raises an exception" do
      expect {
        Pdf::Reader2.new(StringIO.new(""))
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "Pdf has a content stream refers to a non-existant font" do
    let(:filename) { pdf_spec_file("content_stream_refers_to_invalid_font") }

    it "raises an exception" do
      expect {
        reader = Pdf::Reader2.new(filename)
        reader.page(1).text
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "Malformed Pdf" do
    let(:filename) { pdf_spec_file("trailer_root_is_not_a_dict") }

    it "raises an exception if trailer Root is not a dict" do
      Pdf::Reader2.open(filename) do |reader|
        expect { reader.page(1) }.to raise_error(Pdf::Reader2::MalformedPdfError)
      end
    end
  end

  context "Pdf with missing page data" do
    let(:filename) { pdf_spec_file("invalid_pages") }

    it "raises a MalformedPdfError when an InvalidPageError is raised internally" do
      Pdf::Reader2.open(filename) do |reader|
        expect { reader.pages }.to raise_error(Pdf::Reader2::MalformedPdfError)
      end
    end
  end

  context "Pdf that has a content stream with a broken string" do
    let(:filename) { pdf_spec_file("broken_string") }

    # this file used to get us into a hard, endless loop. Make sure that doesn't still happen
    it "doesn't hang when extracting doc info" do
      Timeout::timeout(3) do
        expect {
          reader = Pdf::Reader2.new(filename)
          reader.info
        }.to raise_error(Pdf::Reader2::MalformedPdfError)
      end
    end
  end

  context "gh-217" do
    let(:filename) { pdf_spec_file("gh-217") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-222" do
    let(:filename) { pdf_spec_file("gh-222") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  # The top level Pages object is corrupted and has no Count or Type key
  context "gh-223" do
    let(:filename) { pdf_spec_file("gh-223") }

    it "parses without error" do
      expect {
        parse_pdf(filename)
      }.to_not raise_error
    end

    it "has zero pages" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page_count).to eq 0
        expect(reader.pages).to eq []
      end
    end
  end

  context "gh-224" do
    let(:filename) { pdf_spec_file("gh-224") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-227" do
    let(:filename) { pdf_spec_file("gh-227") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-228" do
    let(:filename) { pdf_spec_file("gh-228") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-229" do
    let(:filename) { pdf_spec_file("gh-229") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-230" do
    let(:filename) { pdf_spec_file("gh-230") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-231" do
    let(:filename) { pdf_spec_file("gh-231") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-232" do
    let(:filename) { pdf_spec_file("gh-232") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-234" do
    let(:filename) { pdf_spec_file("gh-234") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-235" do
    let(:filename) { pdf_spec_file("gh-235") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-236" do
    let(:filename) { pdf_spec_file("gh-236") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-237" do
    let(:filename) { pdf_spec_file("gh-237") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-238" do
    let(:filename) { pdf_spec_file("gh-238") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-239" do
    let(:filename) { pdf_spec_file("gh-239") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-240" do
    let(:filename) { pdf_spec_file("gh-240") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-241" do
    let(:filename) { pdf_spec_file("gh-241") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "gh-242" do
    let(:filename) { pdf_spec_file("gh-242") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  # This one raised an unexpected exception in v2.0.0, but since v2.6.0 (and PR #372) it works
  # without error
  context "gh-243" do
    let(:filename) { pdf_spec_file("gh-243") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to_not raise_error
    end
  end

  # This one raised an unexpected exception in v2.0.0, but since v2.4.0 (and PR #309) it works
  # without error
  context "gh-244" do
    let(:filename) { pdf_spec_file("gh-244") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to_not raise_error
    end
  end

  # This encrypted Pdf declares an invalid key length. It's not really that we don't support a
  # feature - we'll never support an invalid key length. We raise an unsupported fature error
  # anyway.
  context "gh-245" do
    let(:filename) { pdf_spec_file("gh-245") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::UnsupportedFeatureError)
    end
  end

  context "negative-xref-offset.pdf" do
    let(:filename) { pdf_spec_file("negative-xref-offset") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "content_stream_wrong_args.pdf" do
    let(:filename) { pdf_spec_file("content_stream_wrong_args") }

    it "raises MalformedPdfError when parsed" do
      expect {
        parse_pdf(filename)
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  context "xref_offset_too_low.pdf" do
    let(:filename) { pdf_spec_file("xref_offset_too_low") }

    it "compensates for the error and can extract the paage text" do
      expect {
        parse_pdf(filename)
      }.to_not raise_error

      Pdf::Reader2.open(filename) do |pdf|
        expect(pdf.page(1).text).to eql(
          "The xref offset for the root object (obj 2) is a few bytes too low"
        )
      end
    end
  end

  context "stream_missing_endobj.pdf" do
    let(:filename) { pdf_spec_file("stream_missing_endobj") }

    it "compensates for the error and can extract the paage text" do
      expect {
        parse_pdf(filename)
      }.to_not raise_error

      Pdf::Reader2.open(filename) do |pdf|
        expect(pdf.page(1).text).to eql(
          "Object 4 (content stream) is missing the endobj token"
        )
      end
    end
  end

  # a very basic sanity check that we can open this file and extract interesting data
  def parse_pdf(filename)
    Pdf::Reader2.open(filename) do |reader|
      reader.pdf_version
      reader.info
      reader.metadata
      reader.objects
      reader.page_count

      reader.pages.each do |page|
        page.fonts.to_s
        page.text.to_s
        page.raw_content.to_s
      end
    end
  end
end
