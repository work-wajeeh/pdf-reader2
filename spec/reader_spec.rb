# typed: false
# coding: utf-8

describe Pdf::Reader2 do
  let(:cairo_basic)   { pdf_spec_file("cairo-basic")}
  let(:oo3)           { pdf_spec_file("oo3")}
  let(:no_text_spaces) { pdf_spec_file("no_text_spaces")}
  let(:missing_pages_dict) { pdf_spec_file('missing_pages_dict') }

  describe ".open()" do

    it "passes a reader instance to a block" do
      Pdf::Reader2.open(cairo_basic) do |reader|
        expect(reader.pdf_version).to eql(1.4)
      end
    end
  end

  describe "#pdf_version" do
    it "returns the correct pdf_version" do
      expect(Pdf::Reader2.new(cairo_basic).pdf_version).to eql(1.4)
    end

    it "returns the correct pdf_version" do
      expect(Pdf::Reader2.new(no_text_spaces).pdf_version).to eql(1.4)
    end
  end

  describe "#page_count" do
    context "with cairo-basic" do
      it "returns the correct page_count" do
        expect(Pdf::Reader2.new(cairo_basic).page_count).to eql(2)
      end
    end

    context "with no_text_spaces" do
      it "returns the correct page_count" do
        expect(Pdf::Reader2.new(no_text_spaces).page_count).to eql(6)
      end
    end

    context "with indirect_page_count" do
      it "returns the correct page_count" do
        expect(Pdf::Reader2.new(pdf_spec_file("indirect_page_count")).page_count).to eql(1)
      end
    end

    context "when the Pdf has no pages" do
      it 'raises MalformedPdfError if pages object is missing' do
        expect {
          Pdf::Reader2.new(missing_pages_dict).page_count
        }.to raise_error(Pdf::Reader2::MalformedPdfError)
      end
    end
  end

  describe "#info" do
    it "returns the correct info hash from cairo-basic" do
      info = Pdf::Reader2.new(cairo_basic).info

      expect(info.size).to eql(2)
      expect(info[:Creator]).to eql("cairo 1.4.6 (http://cairographics.org)")
      expect(info[:Producer]).to eql("cairo 1.4.6 (http://cairographics.org)")
    end

    it "returns the correct info hash from no_text_spaces" do
      info = Pdf::Reader2.new(no_text_spaces).info

      expect(info.size).to eql(9)
    end

    it "returns the correct info hash from a file with utf-16 encoded info" do
      info = Pdf::Reader2.new(oo3).info

      expect(info.size).to eql(3)
      expect(info[:Creator]).to  eql "Writer"
      expect(info[:Producer]).to eql "OpenOffice.org 3.2"
      expect(info[:CreationDate]).to eql "D:20101113071546-06'00'"
    end

    it "returns an info hash with strings marked as UTF-8" do
      info = Pdf::Reader2.new(oo3).info

      expect(info[:Creator].encoding).to      eql Encoding::UTF_8
      expect(info[:Producer].encoding).to     eql Encoding::UTF_8
      expect(info[:CreationDate].encoding).to eql Encoding::UTF_8
    end
  end

  describe "#metadata" do
    it "returns nil metadata from cairo-basic" do
      expect(Pdf::Reader2.new(cairo_basic).metadata).to be_nil
    end

    it "returns the correct metadata from no_text_spaces" do
      metadata = Pdf::Reader2.new(no_text_spaces).metadata

      expect(metadata).to be_a_kind_of(String)
      expect(metadata).to include("<x:xmpmeta")
    end

    it "returns the metadata string marked as UTF-8" do
      metadata = Pdf::Reader2.new(no_text_spaces).metadata

      expect(metadata.encoding).to eql Encoding::UTF_8
    end

    it "raises an exception if trailer Root is not a dict" do
      filename = pdf_spec_file("trailer_root_is_not_a_dict")
      pdf = Pdf::Reader2.new(filename)
      expect {
        pdf.metadata
      }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  describe "#pages" do
    it "returns an array of pages from cairo-basic" do
      pages = Pdf::Reader2.new(cairo_basic).pages

      expect(pages).to be_a_kind_of(Array)
      expect(pages.size).to eql(2)
      pages.each do |page|
        expect(page).to be_a_kind_of(Pdf::Reader2::Page)
      end
    end

    it "returns an array of pages from no_text_spaces" do
      pages = Pdf::Reader2.new(no_text_spaces).pages

      expect(pages).to be_a_kind_of(Array)
      expect(pages.size).to eql(6)
      pages.each do |page|
        expect(page).to be_a_kind_of(Pdf::Reader2::Page)
      end
    end

    it "raises aMalformedPdfError when an InvalidPageError is raised internally" do
      reader = Pdf::Reader2.new(pdf_spec_file("invalid_pages"))
      expect { reader.pages }.to raise_error(Pdf::Reader2::MalformedPdfError)
    end
  end

  describe "#page" do
    it "returns a single page from cairo-basic" do
      expect(Pdf::Reader2.new(cairo_basic).page(1)).to be_a_kind_of(Pdf::Reader2::Page)
    end

    it "returns a single page from no_text_spaces" do
      expect(Pdf::Reader2.new(no_text_spaces).page(1)).to be_a_kind_of(Pdf::Reader2::Page)
    end

    it "raises InvalidPageError when an invalid page number is requested" do
      reader = Pdf::Reader2.new(pdf_spec_file("cairo-basic"))
      expect { reader.page(10) }.to raise_error(Pdf::Reader2::InvalidPageError)
    end
  end
end
