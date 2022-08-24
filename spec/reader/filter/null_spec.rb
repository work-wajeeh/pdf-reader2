# typed: false
# coding: utf-8

describe PDF2::Reader2::Filter::Null do
  describe "#filter" do
    it "returns the data unchanged" do
      filter = PDF2::Reader2::Filter::Null.new
      expect(filter.filter("\x00")).to eql("\x00")
    end
  end
end
