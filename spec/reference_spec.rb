# typed: false
# coding: utf-8

describe Pdf2::Reader2::Reference do
  describe "#hash" do

    it "returns the same hash for 2 identical objects" do
      one = Pdf2::Reader2::Reference.new(1,0)
      two = Pdf2::Reader2::Reference.new(1,0)

      expect(one.hash).to eq(two.hash)
    end

  end

  describe "#==" do

    it "returns true for the same object" do
      one = Pdf2::Reader2::Reference.new(1,0)

      expect(one == one).to be_truthy
    end

    it "returns true for 2 identical objects" do
      one = Pdf2::Reader2::Reference.new(1,0)
      two = Pdf2::Reader2::Reference.new(1,0)

      expect(one == two).to be_truthy
    end

    it "returns false if one object isn't a Reference" do
      one = Pdf2::Reader2::Reference.new(1,0)

      expect(one == "two").to be_falsey
    end

  end
end
