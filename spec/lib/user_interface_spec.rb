# frozen_string_literal: true

require "./lib/user_interface"

describe UserInterface do
  describe ".fetch_translations" do
    let(:translations_content) do
      <<~TRANSLATIONS
        key: key1.value
        en: English1
        fr: French
        key: key2.value
        en: English2
        fr: French
      TRANSLATIONS
    end

    before do
      ENV["EDITOR"] = <<~EDITOR.strip
        perl -e '
          open my $fh, ">", $ARGV[0];
          print $fh "#{translations_content}";
          close $fh;
        '
      EDITOR
    end

    it "returns the expected data structure" do
      translations = described_class.fetch_translations

      expect(translations).to be_an(Array)
      expect(translations[0]["key"]).to eq("key1.value")
      expect(translations[0]["en"]).to eq("English1")

      expect(translations[1]["key"]).to eq("key2.value")
      expect(translations[1]["en"]).to eq("English2")
    end

    it "removes the temp file" do
      described_class.fetch_translations

      expect(File).not_to exist(described_class::TEMP_FILE_PATH)
    end

    context "when there is a new line in the translation" do
      let(:translations_content) do
        <<~TRANSLATIONS
          key: key1.value
          en: English1
          new line
          fr: French
          key: key2.value
          en: English2
          fr: French
        TRANSLATIONS
      end

      before do
        ENV["EDITOR"] = <<~EDITOR.strip
          perl -e '
            open my $fh, ">", $ARGV[0];
            print $fh "#{translations_content}";
            close $fh;
          '
        EDITOR
      end

      it "returns the expected data structure" do
        translations = described_class.fetch_translations

        expect(translations).to be_an(Array)
        expect(translations[0]["key"]).to eq("key1.value")
        expect(translations[0]["en"]).to eq("English1 new line")

        expect(translations[1]["key"]).to eq("key2.value")
        expect(translations[1]["en"]).to eq("English2")
      end
    end
  end
end
