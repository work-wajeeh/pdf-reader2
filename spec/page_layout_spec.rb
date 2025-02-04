# typed: false
# coding: utf-8

describe Pdf::Reader2::PageLayout do
  describe "#to_s" do
    context "with an A4 page" do
      let(:mediabox) { Pdf::Reader2::Rectangle.new(0, 0, 595.28, 841.89)}

      context "with no words" do
        subject { Pdf::Reader2::PageLayout.new([], mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("")
        end
      end

      context "with only blank word(s)" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(30, 700, 50, 12, "")
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("")
        end
      end

      context "with one word" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(30, 700, 50, 12, "Hello")
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("Hello")
        end
      end
      context "with one run directly below another" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(30, 700, 50, 12, "Hello"),
            Pdf::Reader2::TextRun.new(30, 687, 50, 12, "World"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("Hello\nWorld")
        end
      end
      context "with one two words on one line, separated by a font size gap" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(30, 700, 50, 12, "Hello"),
            Pdf::Reader2::TextRun.new(92, 700, 50, 12, "World"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("Hello World")
        end
      end

      context "with two words on one line, separated just over the mean glyph width" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(30, 700, 50, 12, "Hello"),
            Pdf::Reader2::TextRun.new(91, 700, 50, 12, "World"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("Hello World")
        end
      end

      context "with one two words on one line, separated just over 2x the mean glyph width" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(30, 700, 50, 12, "Hello"),
            Pdf::Reader2::TextRun.new(101, 700, 50, 12, "World"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("Hello  World")
        end
      end

      context "with one run directly below another and indented by just over 1 font size gap" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(30, 700, 50, 12, "Hello"),
            Pdf::Reader2::TextRun.new(43, 687, 50, 12, "World"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("Hello\n World")
        end
      end

      context "with one run directly below another and the first indented by just over 1x fs gap" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(43, 700, 50, 12, "Hello"),
            Pdf::Reader2::TextRun.new(30, 687, 50, 12, "World"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq(" Hello\nWorld")
        end
      end

      context "with one run directly below another with 1 font size gap" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(30, 700, 50, 12, "Hello"),
            Pdf::Reader2::TextRun.new(30, 676, 50, 12, "World"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("Hello\n\nWorld")
        end
      end

      context "with one run that has an implausible font size of 0" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(30, 700, 50, 0, "Hello"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("Hello")
        end
      end

      context "with one run that's positioned at 0,0" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(0, 0, 50, 18, "Hello World"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("Hello World")
        end
      end

      context "with two runs that overlap to make fake 'bold', using the same Y offset" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(420.74, 636.0, 6.67, 12, "b"),
            Pdf::Reader2::TextRun.new(427.41, 636.0, 6.67, 12, "o"),
            Pdf::Reader2::TextRun.new(434.08, 636.0, 2.66, 12, "l"),
            Pdf::Reader2::TextRun.new(436.75, 636.0, 6.67, 12, "d"),
            Pdf::Reader2::TextRun.new(420.84, 636.0, 6.67, 12, "b"),
            Pdf::Reader2::TextRun.new(427.51, 636.0, 6.67, 12, "o"),
            Pdf::Reader2::TextRun.new(434.18, 636.0, 2.66, 12, "l"),
            Pdf::Reader2::TextRun.new(436.85, 636.0, 6.67, 12, "d"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("bold")
        end
      end

      context "with two runs that overlap to make fake 'bold', using different X+Y offset" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(420.74, 635.95, 6.67, 12, "b"),
            Pdf::Reader2::TextRun.new(427.41, 635.95, 6.67, 12, "o"),
            Pdf::Reader2::TextRun.new(434.08, 635.95, 2.66, 12, "l"),
            Pdf::Reader2::TextRun.new(436.75, 635.95, 6.67, 12, "d"),
            Pdf::Reader2::TextRun.new(420.84, 636.05, 6.67, 12, "b"),
            Pdf::Reader2::TextRun.new(427.51, 636.05, 6.67, 12, "o"),
            Pdf::Reader2::TextRun.new(434.18, 636.05, 2.66, 12, "l"),
            Pdf::Reader2::TextRun.new(436.85, 636.05, 6.67, 12, "d"),
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox)}

        it "returns a correct string" do
          expect(subject.to_s).to eq("bold")
        end
      end
      context "with one word and the mediabox is provided as a 4-element array" do
        let!(:runs) do
          [
            Pdf::Reader2::TextRun.new(30, 700, 50, 12, "Hello")
          ]
        end
        subject { Pdf::Reader2::PageLayout.new(runs, mediabox.to_a)}

        it "returns a correct string and prints a deprecation warning" do
          expect(subject.to_s).to eq("Hello")
        end
      end
    end
    context "with a page that's too small to fit any of the text" do
      let(:mediabox) { Pdf::Reader2::Rectangle.new(0, 0, 46.560, 32.640)}
      let(:font_size) { 72 }

      it "returns an empty string" do
        run = Pdf::Reader2::TextRun.new(0, 0, 50, font_size, "a")
        layout = Pdf::Reader2::PageLayout.new([run], mediabox)
        expect(layout.to_s).to eq("")
      end
    end

  end
end
