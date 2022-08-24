# typed: false
# coding: utf-8

# These specs are a kind of integration spec. They're not unit testing small pieces
# of code, it's just parsing a range of Pdf files and ensuring the result is
# consistent. An extra check to make sure parsing these files will continue
# to work for our users.
#
# Where possible, specs that unit test correctly should be written in addition to
# these

describe Pdf::Reader2, "integration specs" do

  context "cairo-unicode-short" do
    let(:filename) { pdf_spec_file("cairo-unicode-short") }

    it "extracts unicode strings correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eql("Chunky Bacon")
      end
    end

    it "extracts unicode strings correctly from part of the page" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(
          page.text(rect: Pdf::Reader2::Rectangle.new(29, 779, 100, 800))
        ).to eql("Chunky")
      end
    end

    # This spec assumes high precision in our glyph positioning calcualtions. It's likely
    # that the specific x,y co-ords tested here might change a bit over time as small bugs
    # in glyph positioning are ironed out (kerning, etc). I still think this test is worthwhile,
    # to confirm the positions don't change unintentionally.
    #
    # pitstop co-ords
    # C 32.0176, 779.5879
    # h 48.8279, 779.89
    # u 60.2067, 779.5879
    # n 73.8355, 779.89
    # k 87.3393, 779.89
    # y 97.3745, 775.4526
    it "extracts individual chars with correct positions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        some_runs = page.runs(
          merge: false,
          rect: Pdf::Reader2::Rectangle.new(29, 779, 100, 800)
        )
        expect(some_runs.size).to eql(6)
        expect(some_runs[0].text).to eql("C")
        expect(some_runs[0].origin).to be_close_to(Pdf::Reader2::Point.new(30,779.89))
        expect(some_runs[1].text).to eql("h")
        expect(some_runs[1].origin).to be_close_to(Pdf::Reader2::Point.new(44.89,779.89))
        expect(some_runs[2].text).to eql("u")
        expect(some_runs[2].origin).to be_close_to(Pdf::Reader2::Point.new(58.39, 779.89))
        expect(some_runs[3].text).to eql("n")
        expect(some_runs[3].origin).to be_close_to(Pdf::Reader2::Point.new(71.89, 779.89))
        expect(some_runs[4].text).to eql("k")
        expect(some_runs[4].origin).to be_close_to(Pdf::Reader2::Point.new(85.40, 779.89))
        expect(some_runs[5].text).to eql("y")
        expect(some_runs[5].origin).to be_close_to(Pdf::Reader2::Point.new(96.73, 779.89))
      end
    end

    it "is portrait orientation" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.orientation).to eql("portrait")
      end
    end

    it "returns correct page dimensions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        # A4 portrait
        expect(page.width).to be_within(0.1).of(595.28)
        expect(page.height).to be_within(0.1).of(841.89)
      end
    end

    it "returns correct origin" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.origin).to eq Pdf::Reader2::Point.new(0,0)
      end
    end
  end

  context "vertical-text-in-identity-v" do
    let(:filename) { pdf_spec_file("vertical-text-in-identity-v") }

    it "interprets Identity-V encoded strings correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text.split.map(&:strip)).to eql(%w{V e r t i c a l T e x t})
      end
    end
  end

  context "adobe_sample" do
    let(:filename) { pdf_spec_file("adobe_sample") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to include("This is a sample Pdf file")
        expect(page.text).to include("If you can read this, you already have Adobe Acrobat")
      end
    end
  end

  context "dutch Pdf with NBSP characters" do
    let(:filename) { pdf_spec_file("dutch") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.pages.size).to eql(3)

        page = reader.page(1)
        expect(page.text).to include(
          "Dit\302\240is\302\240een\302\240pdf\302\240test\302\240van\302\240drie\302\240pagina"
        )
        expect(page.text).to include("’s")
        expect(page.text).to include("Pagina\302\2401")
      end
    end
  end

  context "Pdf with a difference table" do
    let(:filename) { pdf_spec_file("difference_table") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eql("Goiás")
      end
    end
  end

  context "Pdf with a difference table (v2)" do
    let(:filename) { pdf_spec_file("difference_table2") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eql("This Pdf contains ligatures,for example in “ﬁle”and “ﬂoor”.")
      end
    end
  end

  context "Pdf with a content stream that has trailing whitespace" do
    let(:filename) { pdf_spec_file("content_stream_trailing_whitespace") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to match(/Tax\s+Invoice/)
      end
    end
  end

  context "Pdf with a content stream that is enclosed with CR characters only" do
    let(:filename) { pdf_spec_file("content_stream_cr_only") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("This is a weird Pdf file")
      end
    end
  end

  context "Pdf with a content stream that is missing an operator (has hanging params)" do
    let(:filename) { pdf_spec_file("content_stream_missing_final_operator") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to match(/Locatrix/)
        expect(reader.page(2).text).to match(/Ubuntu/)
      end
    end
  end

  # this spec is to detect an hard lock issue some people were encountering on some OSX
  # systems. Real pain to debug.
  context "Pdf with a string containing a high byte (D1) under MacRomanEncoding" do
    let(:filename) { pdf_spec_file("hard_lock_under_osx") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text[0,1]).to eql("’")
      end
    end
  end

  context "Pdf with a stream that has its length specified as an indirect reference" do
    let(:filename) { pdf_spec_file("content_stream_with_length_as_ref") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to eql("Hello World")
      end
    end
  end

  # Pdf::Reader2::XRef#object was saving an incorrect position when seeking. We
  # were saving the current pos of the underlying IO stream, then seeking back
  # to it. This was fine, except when there was still content in the buffer.
  context "Pdf with a stream length specified via indirect object and uses windows line breaks" do
    let(:filename) { pdf_spec_file("content_stream_with_length_as_ref_and_windows_breaks") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to eql("Hello World")
      end
    end
  end

  context "Pdf that uses an ASCII85Decode filter" do
    let(:filename) { pdf_spec_file("ascii85_filter") }

    # The text on this page is rotated 45 degrees, so mapping it to plain text isn't straight
    # forward. Still, it'd be nice to see if this can be improved somehow
    #
    # If not, maybe it'd be good to drop this spec, and replace it with one that confirms the text
    # position if a few key characters
    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        lines = reader.page(1).text.split("\n")
        expect(lines[0].strip).to eq("E")
        expect(lines[1].strip).to eq("t Iu")
      end
    end
  end

  context "Pdf that has an inline image in a content stream with no line breaks" do
    let(:filename) { pdf_spec_file("inline_image_single_line_content_stream") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text.strip[0,7]).to eql("WORKING")
      end
    end
  end

  context "Pdf that has dummy inline data no white-space before EI" do
    let(:filename) { pdf_spec_file("inline_data_followed_by_ei") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to eql("ID followed by EI on same line\n__END__")
      end
    end
  end

  context "Pdf that uses Form XObjects to repeat content" do
    let(:filename) { pdf_spec_file("form_xobject") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to eql("James Healy")
        expect(reader.page(2).text).to eql("James Healy")
      end
    end
  end

  context "Pdf that uses Form XObjects to repeat content" do
    let(:filename) { pdf_spec_file("form_xobject_more") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to include("Some regular content")
        expect(reader.page(1).text).to include("James Healy")
        expect(reader.page(2).text).to include("€10")
        expect(reader.page(2).text).to include("James Healy")
      end
    end
  end

  context "Pdf that uses indirect Form XObjects to repeat content" do
    let(:filename) { pdf_spec_file("indirect_xobject") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).not_to be_nil
      end
    end
  end

  context "Pdf that has a Form XObjects that references itself" do
    let(:filename) { pdf_spec_file("form_xobject_recursive") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to include("this form XObject contains a reference to itself")
      end
    end
  end

  context "Pdf that uses multiple content streams for a single page" do
    let(:filename) { pdf_spec_file("split_params_and_operator") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to include("My name is")
        expect(reader.page(1).text).to include("James Healy")
      end
    end
  end

  context "Pdf that has a single space after the EOF marker" do
    let(:filename) { pdf_spec_file("space_after_eof") }

    # This text is rotated at 45 degrees, which isn't particularly easy to map to plain text
    # It would be nice if all the "Hello World" characters were at least visible though
    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to eql("    r\n loo\nHe")
      end
    end
  end

  context "Pdf that was generated in open office 3" do
    let(:filename) { pdf_spec_file("oo3") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to include("test")
      end
    end
  end

  context "Pdf has newlines at the start of a content stream" do
    let(:filename) { pdf_spec_file("content_stream_begins_with_newline") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to eql("This file has a content stream that begins with \\n\\n")
      end
    end
  end

  context "encrypted_version1_revision2_40bit_rc4_user_pass_apples" do
    let(:filename) { pdf_spec_file("encrypted_version1_revision2_40bit_rc4_user_pass_apples") }

    context "with the user pass" do
      let(:pass) { "apples" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'",
            :ModDate=>"D:20170115142929+11'00'"
          )
        end
      end
    end

    context "with the owner pass" do
      let(:pass) { "password" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'",
            :ModDate=>"D:20170115142929+11'00'"
          )
        end
      end
    end
  end

  context "encrypted_version1_revision2_128bit_rc4_blank_user_password" do
    let(:filename) { pdf_spec_file("encrypted_version1_revision2_128bit_rc4_blank_user_password") }

    context "with no user pass" do
      it "correctly extracts text" do
        Pdf::Reader2.open(filename) do |reader|
          expect(reader.page(1).text).to eql("WOOOOO DOCUMENT!")
        end
      end
    end

    context "with the owner pass" do
      it "correctly extracts text"
    end
  end

  context "encrypted_version2_revision3_128bit_rc4_blank_user_pass" do
    let(:filename) { pdf_spec_file("encrypted_version2_revision3_128bit_rc4_blank_user_pass") }

    context "with no user pass" do
      it "correctly extracts text" do
        Pdf::Reader2.open(filename) do |reader|
          expect(reader.page(1).text).to eql("This sample file is encrypted with no user password")
        end
      end
    end

    context "with the owner pass" do
      it "correctly extracts text"
    end

  end

  context "encrypted_version1_revision2_128bit_rc4_no_doc_id" do
    let(:filename) {pdf_spec_file("encrypted_version1_revision2_128bit_rc4_no_doc_id") }

    context "with no user pass" do
      it "correctly extracts text" do
        Pdf::Reader2.open(filename) do |reader|
          expect(reader.page(1).text).to eql(
            "This encryped file breaks compatability with the Pdf spec " \
            "because it has no document ID"
          )
        end
      end
    end

    context "with the owner pass" do
      it "correctly extracts text"
    end
  end

  context "encrypted_version2_revision3_128bit_rc4_user_pass_apples" do
    let(:filename) { pdf_spec_file("encrypted_version2_revision3_128bit_rc4_user_pass_apples") }

    context "with the user pass" do
      let(:pass) { "apples" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'"
          )
        end
      end
    end

    context "with the owner pass" do
      let(:pass) { "password" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'"
          )
        end
      end
    end

    context "with no pass" do
      it "raises an exception" do
        expect {
          Pdf::Reader2.open(filename) do |reader|
            reader.page(1).text
          end
        }.to raise_error(Pdf::Reader2::EncryptedPdfError)
      end
    end
  end

  context "encrypted_version4_revision_4user_pass_apples_enc_metadata" do
    let(:filename) {
      pdf_spec_file("encrypted_version4_revision4_128bit_rc4_user_pass_apples_enc_metadata")
    }

    context "with the user pass" do
      let(:pass) { "apples" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'",
            :ModDate=>"D:20170114125054+11'00'"
          )
        end
      end
    end
    context "with the owner pass" do
      let(:pass) { "password" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'",
            :ModDate=>"D:20170114125054+11'00'"
          )
        end
      end
    end
  end

  context "encrypted_version4_revision4_128bit_rc4_user_pass_apples_unenc_metadata" do
    let(:filename) {
      pdf_spec_file("encrypted_version4_revision4_128bit_rc4_user_pass_apples_unenc_metadata")
    }

    context "with the user pass" do
      let(:pass) { "apples" }
      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'",
            :ModDate => "D:20170114125141+11'00'"
          )
        end
      end
    end
    context "with the owner pass" do
      let(:pass) { "password" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'",
            :ModDate => "D:20170114125141+11'00'"
          )
        end
      end
    end
  end

  context "encrypted_version4_revision4_128bit_aes_user_pass_apples_enc_metadata" do
    let(:filename) {
      pdf_spec_file("encrypted_version4_revision4_128bit_aes_user_pass_apples_enc_metadata")
    }

    context "with the user pass" do
      let(:pass) { "apples" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :CreationDate=>"D:20110814231057+10'00'",
            :Creator=>"Writer",
            :ModDate=>"D:20170115224117+11'00'",
            :Producer=>"LibreOffice 3.3",
          )
        end
      end
    end

    context "with the owner pass" do
      let(:pass) { "password" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :CreationDate=>"D:20110814231057+10'00'",
            :Creator=>"Writer",
            :ModDate=>"D:20170115224117+11'00'",
            :Producer=>"LibreOffice 3.3",
          )
        end
      end

    end
  end

  context "encrypted_version4_revision4_128bit_aes_user_pass_apples_unenc_metadata" do
    let(:filename) {
      pdf_spec_file("encrypted_version4_revision4_128bit_aes_user_pass_apples_unenc_metadata")
    }

    context "with the user pass" do
      let(:pass) { "apples" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :CreationDate=>"D:20110814231057+10'00'",
            :Creator=>"Writer",
            :ModDate=>"D:20170115224244+11'00'",
            :Producer=>"LibreOffice 3.3",
          )
        end
      end

    end

    context "with the owner pass" do
      let(:pass) { "password" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :CreationDate=>"D:20110814231057+10'00'",
            :Creator=>"Writer",
            :ModDate=>"D:20170115224244+11'00'",
            :Producer=>"LibreOffice 3.3",
          )
        end
      end

    end
  end

  context "encrypted_version5_revision5_256bit_aes_user_pass_apples_enc_metadata" do
    let(:filename) {
      pdf_spec_file("encrypted_version5_revision5_256bit_aes_user_pass_apples_enc_metadata")
    }

    context "with the user pass" do
      let(:pass) { "apples" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
                                     :Author => "Gyuchang Jun",
                                     :CreationDate => "D:20170312093033+00'00'",
                                     :Creator => "Microsoft Word",
                                     :ModDate => "D:20170312093033+00'00'"
                                 )
        end
      end
    end

    context "with the owner pass" do
      let(:pass) { "password" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
                                     :Author => "Gyuchang Jun",
                                     :CreationDate => "D:20170312093033+00'00'",
                                     :Creator => "Microsoft Word",
                                     :ModDate => "D:20170312093033+00'00'"
                                 )
        end
      end

    end
  end

  context "encrypted_version5_revision5_256bit_aes_user_pass_apples_unenc_metadata" do
    let(:filename) {
      pdf_spec_file("encrypted_version5_revision5_256bit_aes_user_pass_apples_unenc_metadata")
    }

    context "with the user pass" do
      let(:pass) { "apples" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
                                     :Author => "Gyuchang Jun",
                                     :CreationDate => "D:20170312093033+00'00'",
                                     :Creator => "Microsoft Word",
                                     :ModDate => "D:20170312093033+00'00'"
                                 )
        end
      end

    end

    context "with the owner pass" do
      let(:pass) { "password" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to include("This sample file is encrypted")
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
                                     :Author => "Gyuchang Jun",
                                     :CreationDate => "D:20170312093033+00'00'",
                                     :Creator => "Microsoft Word",
                                     :ModDate => "D:20170312093033+00'00'"
                                 )
        end
      end

    end
  end

  context "encrypted_version5_revision6_256bit_aes_user_pass_apples_enc_metadata" do
    let(:filename) {
      pdf_spec_file("encrypted_version5_revision6_256bit_aes_user_pass_apples_enc_metadata")
    }

    context "with the user pass" do
      let(:pass) { "apples" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to start_with(
            "This sample file is encrypted with a user password"
          )
        end
      end
      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'",
            :ModDate=>"D:20170115224358+11'00'"
          )
        end
      end
    end

    context "with the owner pass" do
      let(:pass) { "password" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to start_with(
            "This sample file is encrypted with a user password"
          )
        end
      end
      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'",
            :ModDate=>"D:20170115224358+11'00'"
          )
        end
      end
    end
  end

  context "encrypted_version5_revision6_256bit_aes_user_pass_apples_unenc_metadata" do
    let(:filename) {
      pdf_spec_file("encrypted_version5_revision6_256bit_aes_user_pass_apples_unenc_metadata")
    }

    context "with the user pass" do
      let(:pass) { "apples" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to start_with(
            "This sample file is encrypted with a user password"
          )
        end
      end

      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'",
            :ModDate=>"D:20170115224526+11'00'"
          )
        end
      end
    end

    context "with the owner pass" do
      let(:pass) { "password" }

      it "correctly extracts text" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.page(1).text).to start_with(
            "This sample file is encrypted with a user password"
          )
        end
      end
      it "correctly extracts info" do
        Pdf::Reader2.open(filename, :password => pass) do |reader|
          expect(reader.info).to eq(
            :Creator=>"Writer",
            :Producer=>"LibreOffice 3.3",
            :CreationDate=>"D:20110814231057+10'00'",
            :ModDate=>"D:20170115224526+11'00'"
          )
        end
      end
    end
  end

  context "Encrypted Pdf with an xref stream" do
    let(:filename) {
      pdf_spec_file("encrypted_and_xref_stream")
    }

    it "correctly extracts text" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to eq("This text is encrypted")
      end
    end

    it "correctly parses indirect objects" do
      Pdf::Reader2.open(filename) do |reader|
        expect { reader.objects.values }.not_to raise_error
      end
    end
  end

  context "Pdf with inline images" do
    let(:filename) { pdf_spec_file("inline_image") }

    it "extracts inline images correctly" do
      @browser = Pdf::Reader2.new(filename)
      @page    = @browser.page(1)

      receiver = Pdf::Reader2::RegisterReceiver.new
      @page.walk(receiver)

      callbacks = receiver.series(:begin_inline_image, :begin_inline_image_data, :end_inline_image)

      # inline images should trigger 3 callbacks. The first with no args.
      expect(callbacks[0]).to eql(:name => :begin_inline_image, :args => [])

      # the second with the image header (colorspace, etc)
      expect(callbacks[1]).to eql(
        :name => :begin_inline_image_data,
        :args => [:CS, :RGB, :I, true, :W, 234, :H, 70, :BPC, 8]
      )

      # the last with the image data
      expect(callbacks[2][:name]).to eql :end_inline_image
      image_data =  callbacks[2][:args].first

      expect(image_data).to be_a(String)
      expect(image_data.size).to  eql 49140
      expect(image_data[0,3].unpack("C*")).to   eql [255,255,255]
      expect(image_data[-3,3].unpack("C*")).to  eql [255,255,255]
    end
  end

  context "Pdf with a page that has multiple content streams" do
    let(:filename) { pdf_spec_file("content_stream_as_array") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to include("Arkansas Declaration Relating")
      end
    end
  end

  context "Pdf with a junk prefix" do
    let(:filename) { pdf_spec_file("junk_prefix") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eql("This Pdf contains junk before the %-Pdf marker")
      end
    end
  end

  context "Pdf with a 1024 bytes of junk prefix" do
    let(:filename) { pdf_spec_file("junk_prefix_1024") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eql("This Pdf contains junk before the %-Pdf marker")
      end
    end
  end

  context "Pdf that has a cmap entry that uses ligatures" do
    let(:filename) { pdf_spec_file("ligature_integration_sample") }

    it "extracts text correctly" do
      # there are two locations in the following pdf that have the following sequence
      # [ 85,   68,   73,    192,        70]   after cmap translation this should yield
      # [[114], [97], [102], [102, 105], [99]] or more specifically
      # [r,     a,    f,     fi,         c]
      #
      # prior to commit d37b4bf52e243dfb999fa0cda791449c50f6d16d
      # the fi would be returned as f

      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        m = /raffic/.match(page.text)
        expect(m[0].to_s).to eql("raffic")
      end
    end
  end

  context "Pdf that has a cmap entry that contains surrogate pairs" do
    let(:filename) { pdf_spec_file("surrogate_pair_integration_sample") }

    it "extracts text correctly" do
      # the following pdf has a sequence in it that requires 32-bit Unicode, pdf requires
      # all text to be stored in 16-bit. To acheive this surrogate-pairs are used. cmap
      # converts the surrogate-pairs back to 32-bit and ruby handles them nicely.
      # the following sequence exists in this pdf page
      # \u{1d475}\u{1d468}\u{1d47a}\u{1d46a}\u{1d468}\u{1d479} => NASCAR
      # these codepoints are in the "Math Alphanumeric Symbols (Italic) section of Unicode"
      #
      # prior to commit d37b4bf52e243dfb999fa0cda791449c50f6d16d
      # pdf-reader2 would return Nil instead of the correct unicode character
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        # 𝑵𝑨𝑺𝑪𝑨𝑹
        utf8_str = [0x1d475, 0x1d468, 0x1d47a, 0x1d46a, 0x1d468, 0x1d479].pack("U*")
        expect(page.text).to include(utf8_str)
      end
    end
  end

  context "Pdf that uses a standatd font and a ligature" do
    let(:filename) { pdf_spec_file("standard_font_with_a_difference") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("The following word uses a ligature: ﬁve")
      end
    end
  end

  context "Pdf that uses a type1 font that isn't embedded and isn't one of the 14 built-ins" do
    let(:filename) { pdf_spec_file("type1-arial") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("This text uses a Type1 font that isn't embedded")
      end
    end
  end

  context "Pdf that uses a TrueType font that isn't embedded and has no metrics" do
    let(:filename) { pdf_spec_file("truetype-arial") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to start_with("This text uses a TrueType font that isn't embedded")
      end
    end
  end

  context "Pdf that uses a type3 bitmap font" do
    let(:filename) { pdf_spec_file("type3_font") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("a\nb\nc")
      end
    end
  end

  context "Pdf that uses a type3 bitmap font with a rare FontMatrix" do
    let(:filename) { pdf_spec_file("type3_font_with_rare_font_matrix") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to include("ParallelGenetic Algorithms")
      end
    end
  end

  context "Pdf with a Type0 font and Encoding is a CMap called OneByteIdentityH" do
    let(:filename) { pdf_spec_file("one-byte-identity") }

    # I'm not 100% confident that we'rr correctly handling OneByteIdentityH files in a way
    # that will always work. It works for the sample file I have though, so that's better than
    # nothing
    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("abc")
      end
    end
  end

  context "Pdf with rotated text" do
    let(:filename) { pdf_spec_file("rotated_text") }

    # TODO this spec isn't ideal as our support for extracting rotated text is quite
    #      rubbish. I've added this to ensure we don't throw an exception with
    #      rotated text. It's a start.
    it "extracts text without raising an exception" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text.split("\n").map(&:strip).slice(0,2)).to eq(["0","9"])
      end
    end
  end

  context "Pdf with a TJ operator that receives an array starting with a number" do
    let(:filename) { pdf_spec_file("TJ_starts_with_a_number") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text[0,18]).to eq("This file has a TJ")
      end
    end
  end

  context "Pdf with a TJ operator that aims to correct for character spacing" do
    let(:filename) { pdf_spec_file("TJ_and_char_spacing") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text[15,17]).to eq("The big brown fox")
      end
    end
  end

  context "Pdf with a page that's missing the MediaBox attribute" do
    let(:filename) { pdf_spec_file("mediabox_missing") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text[0,54]).to eq("This page is missing the compulsory MediaBox attribute")
      end
    end

    it "is portrait orientation" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.orientation).to eql("portrait")
      end
    end

    it "returns correct page dimensions (defaults to portrait US letter)" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.width).to be_within(0.1).of(612)
        expect(page.height).to be_within(0.1).of(792)
      end
    end
  end

  context "Pdf using a standard fint and no difference table" do
    let(:filename) { pdf_spec_file("standard_font_with_no_difference") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("This page uses contains a €")
      end
    end
  end

  context "Pdf using zapf dingbats" do
    let(:filename) { pdf_spec_file("zapf") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to include("✄☎✇")
      end
    end
  end

  context "Pdf using symbol text" do
    let(:filename) { pdf_spec_file("symbol") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to include("θρ")
      end
    end
  end

  context "Scanned Pdf with invisible text added by ClearScan" do
    let(:filename) { pdf_spec_file("clearscan") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("This document was scanned and then OCRd with Adobe ClearScan")
      end
    end
  end

  context "Pdf with text that contains a control char" do
    let(:filename) { pdf_spec_file("times-with-control-character") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to include("This text includes an ASCII control")
      end
    end
  end

  context "Pdf where the top-level Pages object has no Type" do
    let(:filename) { pdf_spec_file("pages_object_missing_type") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to include("The top level Pages object has no Type")
      end
    end
  end

  context "Pdf where the entries in a Kids array are direct objects, rather than indirect" do
    let(:filename) { pdf_spec_file("kids-as-direct-objects") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("page 1")
      end
    end
  end

  context "Pdf with text positioned at 0,0" do
    let(:filename) { pdf_spec_file("minimal") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("Hello World")
      end
    end
  end

  context "Pdf with bad xref: using 1 not 0" do
    let(:filename) { pdf_spec_file("minimal-xref-1") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("Hello World")
      end
    end
  end

  context "Pdf with octal data" do
    let(:filename) { pdf_spec_file("octal101") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("A ]A[")
      end
    end
  end

  context "Pdf with octal data" do
    let(:filename) { pdf_spec_file("octal74") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("< ]<8[")
      end
    end
  end

  context "Pdf with CR line-wrapped text" do
    let(:filename) { pdf_spec_file("textwrapcr") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("aaaa bbbb")
      end
    end
  end

  context "Pdf with LF line-wrapped text" do
    let(:filename) { pdf_spec_file("textwraplf") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("aaaa bbbb")
      end
    end
  end

  context "Pdf with CRLF line-wrapped text" do
    let(:filename) { pdf_spec_file("textwrapcrlf") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("aaaabbbb")
      end
    end
  end

  context "Pdf with LFCR line-wrapped text" do
    let(:filename) { pdf_spec_file("textwraplfcr") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("aaaabbbb")
      end
    end
  end

  context "Pdf with MediaBox specified as an indirect object" do
    let(:filename) { pdf_spec_file("indirect_mediabox") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq("The MediaBox for this page is specified via an indirect object")
      end
    end
  end

  context "Pdf with overlapping chars to achieve fake bold effect" do
    let(:filename) { pdf_spec_file("overlapping-chars-xy-fake-bold") }
    let(:text) {
      "Some characters that overlap with different X and Y to achieve a fake bold effect"
    }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq(text)
      end
    end
  end

  context "Pdf with overlapping chars (same Y pos) to achieve fake bold effect" do
    let(:filename) { pdf_spec_file("overlapping-chars-x-fake-bold") }
    let(:text) {
      "Some characters that overlap with different X to achieve a fake bold effect"
    }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq(text)
      end
    end
  end

  context "Pdf with 180 page rotation followed by matrix transformations to undo it" do
    let(:filename) { pdf_spec_file("rotate-180") }
    let(:text) {
      "This text is rendered upside down\nand then the page is rotated"
    }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq(text)
      end
    end

    # This spec assumes high precision in our glyph positioning calcualtions. It's likely
    # that the specific x,y co-ords tested here might change a bit over time as small bugs
    # in glyph positioning are ironed out (kerning, etc). I still think this test is worthwhile,
    # to confirm the positions don't change unintentionally.
    #
    # Pitstop numbers
    #
    # u -437.08, -68.018
    # p -431.054, -70.4555
    # s -424.851, -68.018
    # i -420.4, -67.9
    # d -416.918, -68.018
    # e -410.978, -68.018
    it "extracts individual chars with correct positions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        some_runs = page.runs(
          merge: false,
          rect: Pdf::Reader2::Rectangle.new(-438, -68, -405, -62)
        )
        expect(some_runs.size).to eql(6)
        expect(some_runs[0].text).to eql("u")
        expect(some_runs[0].origin).to be_close_to(Pdf::Reader2::Point.new(-437.24, -67.9))
        expect(some_runs[1].text).to eql("p")
        expect(some_runs[1].origin).to be_close_to(Pdf::Reader2::Point.new(-431.24, -67.9))
        expect(some_runs[2].text).to eql("s")
        expect(some_runs[2].origin).to be_close_to(Pdf::Reader2::Point.new(-425.34, -67.9))
        expect(some_runs[3].text).to eql("i")
        expect(some_runs[3].origin).to be_close_to(Pdf::Reader2::Point.new(-420.65, -67.9))
        expect(some_runs[4].text).to eql("d")
        expect(some_runs[4].origin).to be_close_to(Pdf::Reader2::Point.new(-417.35, -67.9))
        expect(some_runs[5].text).to eql("e")
        expect(some_runs[5].origin).to be_close_to(Pdf::Reader2::Point.new(-411.26, -67.9))
      end
    end

    it "is portrait orientation" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.orientation).to eql("portrait")
      end
    end

    it "returns correct page dimensions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        # A4 portrait
        expect(page.width).to be_within(0.1).of(595.30)
        expect(page.height).to be_within(0.1).of(841.88)
      end
    end

    it "returns correct origin" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.origin.x).to be_within(0.1).of(-595.30)
        expect(page.origin.y).to be_within(0.1).of(-841.88)
      end
    end
  end

  context "Pdf with page rotation of 270 degrees followed by matrix transformations to undo it" do
    let(:filename) { pdf_spec_file("rotate-then-undo") }
    let(:text) {
      "This page uses matrix transformations to print text   sideways, " +
      "then has a Rotate key to fix it"
    }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq(text)
      end
    end

    # This spec assumes high precision in our glyph positioning calcualtions. It's likely
    # that the specific x,y co-ords tested here might change a bit over time as small bugs
    # in glyph positioning are ironed out (kerning, etc). I still think this test is worthwhile,
    # to confirm the positions don't change unintentionally.
    #
    # Pitstop Numbers
    #
    # T -570.28, 750.95
    # h -560.86, 750.95
    # i -553.38, 750.95
    # s -550.68, 750.76
    #
    it "extracts individual chars with correct positions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        some_runs = page.runs(
          merge: false,
          rect: Pdf::Reader2::Rectangle.new(-572, 749, -545, 760)
        )
        expect(some_runs.size).to eql(4)
        expect(some_runs[0].text).to eql("T")
        expect(some_runs[0].origin).to be_close_to(Pdf::Reader2::Point.new(-570.24, 750.95))
        expect(some_runs[1].text).to eql("h")
        expect(some_runs[1].origin).to be_close_to(Pdf::Reader2::Point.new(-561.95, 750.95))
        expect(some_runs[2].text).to eql("i")
        expect(some_runs[2].origin).to be_close_to(Pdf::Reader2::Point.new(-554.40, 750.95))
        expect(some_runs[3].text).to eql("s")
        expect(some_runs[3].origin).to be_close_to(Pdf::Reader2::Point.new(-551.39, 750.95))
      end
    end

    it "is portrait orientation" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.orientation).to eql("portrait")
      end
    end

    it "returns correct page dimensions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        # A4 portrait
        expect(page.width).to be_within(0.1).of(595.30)
        expect(page.height).to be_within(0.1).of(841.88)
      end
    end

    it "returns correct origin" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.origin.x).to be_within(0.1).of(-595.30)
        expect(page.origin.y).to be_within(0.1).of(0)
      end
    end
  end

  context "Pdf with 270° page rotation and matrix transformations within BT block to undo" do
    let(:filename) { pdf_spec_file("rotate-270-then-undo-inside-bt") }
    let(:text) { "This page is rotated 270 degrees" }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq(text)
      end
    end

    # This spec assumes high precision in our glyph positioning calcualtions. It's likely
    # that the specific x,y co-ords tested here might change a bit over time as small bugs
    # in glyph positioning are ironed out (kerning, etc). I still think this test is worthwhile,
    # to confirm the positions don't change unintentionally.
    #
    # Pitstop numbers
    #
    # T -320.736, 534
    # h -312.408, 534
    # i -305.796, 534
    # s -303.408, 533.832
    #
    it "extracts individual chars with correct positions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        some_runs = page.runs(
          merge: false,
          rect: Pdf::Reader2::Rectangle.new(-322, 534, -300, 550)
        )
        expect(some_runs.size).to eql(4)
        expect(some_runs[0].text).to eql("T")
        expect(some_runs[0].origin).to be_close_to(Pdf::Reader2::Point.new(-320.2, 534.5))
        expect(some_runs[1].text).to eql("h")
        expect(some_runs[1].origin).to be_close_to(Pdf::Reader2::Point.new(-312.86, 534.5))
        expect(some_runs[2].text).to eql("i")
        expect(some_runs[2].origin).to be_close_to(Pdf::Reader2::Point.new(-306.19, 534.5))
        expect(some_runs[3].text).to eql("s")
        expect(some_runs[3].origin).to be_close_to(Pdf::Reader2::Point.new(-303.532, 534.5))
      end
    end

    it "is portrait orientation" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.orientation).to eql("portrait")
      end
    end

    it "returns correct page dimensions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        # A4 portrait
        expect(page.width).to be_within(0.1).of(595.30)
        expect(page.height).to be_within(0.1).of(841.88)
      end
    end

    it "returns correct origin" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.origin.x).to be_within(0.1).of(-595.30)
        expect(page.origin.y).to be_within(0.1).of(0)
      end
    end
  end

  context "Pdf with page rotation of 90 degrees followed by matrix transformations to undo it" do
    let(:filename) { pdf_spec_file("rotate-90-then-undo") }
    let(:text) {
      "1: This Pdf has Rotate:90 in the page metadata\n" +
      "2: to get a landscape layout, and then uses matrix\n" +
      "3: transformation to rotate the text back to normal"
    }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to eq(text)
      end
    end

    # This spec assumes high precision in our glyph positioning calcualtions. It's likely
    # that the specific x,y co-ords tested here might change a bit over time as small bugs
    # in glyph positioning are ironed out (kerning, etc). I still think this test is worthwhile,
    # to confirm the positions don't change unintentionally.
    #
    # Pitstop numbers
    #
    # T 287.298, -45.49
    # h 295.626, -45.49
    # i 302.238, -45.49
    # s 304.626, -45.658
    #
    it "extracts individual chars with correct positions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        some_runs = page.runs(
          merge: false,
          rect: Pdf::Reader2::Rectangle.new(285, -47, 310, -35)
        )
        expect(some_runs.size).to eql(4)
        expect(some_runs[0].text).to eql("T")
        expect(some_runs[0].origin).to be_close_to(Pdf::Reader2::Point.new(287.33, -45.49))
        expect(some_runs[1].text).to eql("h")
        expect(some_runs[1].origin).to be_close_to(Pdf::Reader2::Point.new(294.66, -45.49))
        expect(some_runs[2].text).to eql("i")
        expect(some_runs[2].origin).to be_close_to(Pdf::Reader2::Point.new(301.33, -45.49))
        expect(some_runs[3].text).to eql("s")
        expect(some_runs[3].origin).to be_close_to(Pdf::Reader2::Point.new(304, -45.49))
      end
    end

    it "is portrait landscape" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.orientation).to eql("landscape")
      end
    end

    it "returns correct page dimensions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        # A4 landscape
        expect(page.width).to be_within(0.1).of(842)
        expect(page.height).to be_within(0.1).of(595)
      end
    end

    it "returns correct origin" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.origin.x).to be_within(0.1).of(0)
        expect(page.origin.y).to be_within(0.1).of(-595)
      end
    end
  end

  context "Pdf with page rotation of 90 degrees followed by matrix transformations to undo it" do
    let(:filename) { pdf_spec_file("rotate-90-then-undo-with-br-text") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.text).to include("This Pdf ha  sRotate:90 in the page")
        expect(page.text).to include("metadata to get a landscape layout")
        expect(page.text).to include("and text in bottom right quadrant")
      end
    end

    # This spec assumes high precision in our glyph positioning calcualtions. It's likely
    # that the specific x,y co-ords tested here might change a bit over time as small bugs
    # in glyph positioning are ironed out (kerning, etc). I still think this test is worthwhile,
    # to confirm the positions don't change unintentionally.
    #
    # Pitstop Numbers
    #
    # p 216.026, -525.906
    # a 222.398, -523.578
    # g 228.986, -525.906
    # e 235.682, -523.578
    #
    it "extracts individual chars with correct positions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        some_runs = page.runs(
          merge: false,
          rect: Pdf::Reader2::Rectangle.new(212, -524, 239, -520)
        )
        expect(some_runs.size).to eql(4)
        expect(some_runs[0].text).to eql("p")
        expect(some_runs[0].origin).to be_close_to(Pdf::Reader2::Point.new(215.06, -523.41))
        expect(some_runs[1].text).to eql("a")
        expect(some_runs[1].origin).to be_close_to(Pdf::Reader2::Point.new(221.73, -523.41))
        expect(some_runs[2].text).to eql("g")
        expect(some_runs[2].origin).to be_close_to(Pdf::Reader2::Point.new(228.41, -523.41))
        expect(some_runs[3].text).to eql("e")
        expect(some_runs[3].origin).to be_close_to(Pdf::Reader2::Point.new(235.08, -523.41))
      end
    end

    it "is landscape orientation" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.orientation).to eql("landscape")
      end
    end

    it "returns correct page dimensions" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        # A4 landscape
        expect(page.width).to be_within(0.1).of(842)
        expect(page.height).to be_within(0.1).of(595)
      end
    end

    it "returns correct origin" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.origin.x).to be_within(0.1).of(0)
        expect(page.origin.y).to be_within(0.1).of(-595)
      end
    end
  end

  context "Pdf with /Prev 0 trailer entry" do
    let(:filename) { pdf_spec_file("prev0") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to eql("aaaa bbbb")
      end
    end
  end

  context "Content stream with indirect object for filters array" do
    let(:filename) { pdf_spec_file("stream-with-indirect-filters") }

    it "extracts text correctly" do
      Pdf::Reader2.open(filename) do |reader|
        expect(reader.page(1).text).to eql(
          "The content stream for this page stores the filter in an indirect object"
        )
      end
    end
  end

  context "Pdf with text outside the CropBox and MediaBox" do
    let(:filename) { pdf_spec_file("text_outside_cropbox_and_mediabox") }

    it "returns the correct rectangles for the page 1" do
      Pdf::Reader2.open(filename) do |reader|
        page = reader.page(1)
        expect(page.rectangles[:MediaBox]).to eq(Pdf::Reader2::Rectangle.new(0, 0, 612, 792))
        expect(page.rectangles[:CropBox]).to eq(Pdf::Reader2::Rectangle.new(100, 100, 412, 592))
      end
    end

    it "by default only extracts text inside the CropBox" do
      Pdf::Reader2.open(filename) do |reader|
        text = reader.page(1).text
        expect(text).to include("This text is inside the CropBox")
        expect(text).to_not include("Between CropBox and MediaBox")
        expect(text).to_not include("Outside MediaBox")
      end
    end

    it "by default only extracts runs inside the CropBox" do
      Pdf::Reader2.open(filename) do |reader|
        text_from_runs = reader.page(1).runs.map(&:text).join(" ")
        expect(text_from_runs).to include("This text is inside the CropBox")
        expect(text_from_runs).to_not include("Between CropBox and MediaBox")
        expect(text_from_runs).to_not include("Outside MediaBox")
      end
    end

    it "can extract text between CropBox and MediaBox with a custom option" do
      Pdf::Reader2.open(filename) do |reader|
        text = reader.page(1).text(rect: Pdf::Reader2::Rectangle.new(0, 0, 612, 792))
        expect(text).to include("This text is inside the CropBox")
        expect(text).to include("Between CropBox and MediaBox")
        expect(text).to_not include("Outside MediaBox")
      end
    end

    it "can extract runs between CropBox and MediaBox with a custom option" do
      mediabox = Pdf::Reader2::Rectangle.new(0, 0, 612, 792)
      Pdf::Reader2.open(filename) do |reader|
        text_from_runs = reader.page(1).runs(rect: mediabox).map(&:text).join(" ")
        expect(text_from_runs).to include("This text is inside the CropBox")
        expect(text_from_runs).to include("Between CropBox and MediaBox")
        expect(text_from_runs).to_not include("Outside MediaBox")
      end
    end

    # This currently doesn't work - Pdf::Reader2::PageLayout skips text that's outside the MediaBox
    # I'm not sure we want it to work either, but I'm adding it as a pending spec for completeness
    # while I consider the best options
    it "can extract text outside the MediaBox with a custom option"

    it "can extract runs outside the MediaBox with a custom option" do
      larger_than_mediabox = Pdf::Reader2::Rectangle.new(0, 0, 900, 900)
      Pdf::Reader2.open(filename) do |reader|
        text_from_runs = reader.page(1).runs(rect: larger_than_mediabox).map(&:text).join(" ")
        expect(text_from_runs).to include("This text is inside the CropBox")
        expect(text_from_runs).to include("Between CropBox and MediaBox")
        expect(text_from_runs).to include("Outside MediaBox")
      end
    end
  end
end
