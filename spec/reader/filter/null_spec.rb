# typed: false
# coding: utf-8

describe PDF::Reader2::Filter::Null do
  describe "#filter" do
    it "returns the data unchanged" do
      filter = PDF::Reader2::Filter::Null.new
      expect(filter.filter("\x00")).to eql("\x00")
    end
  end
end
