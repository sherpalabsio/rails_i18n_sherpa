# frozen_string_literal: true

require "./add_or_update"

describe AddOrUpdate do
  let(:initial_locale_file_content) do
    <<~HEREDOC
      ---
      {locale}:
        level_1:
          sub_level1: Initial content
    HEREDOC
  end

  let(:en_local_file_content) do
    File.read(File.join("config", "locales", "en.yml"))
  end

  before do
    stub_const("AddOrUpdate::SUPPORTED_LOCALES", %w[en fr])

    AddOrUpdate::SUPPORTED_LOCALES.each do |locale|
      locale_file = File.join("config", "locales", "#{locale}.yml")
      content = initial_locale_file_content.gsub("{locale}", locale)
      FileUtils.mkdir_p(File.dirname(locale_file))
      File.write(locale_file, content)
    end
  end

  after do
    FileUtils.rm_rf("config")
  end

  describe "adding a new translations" do
    let(:translation_from_user) do
      <<~HEREDOC
        key: test.key
        en: Copy en
        fr: Copy fr
      HEREDOC
    end

    it "adds a new translation key" do
      allow_any_instance_of(Object).to receive(:system) do |_, command|
        File.write("/tmp/TRANSLATIONS.yml", translation_from_user) if command.include?("/tmp/TRANSLATIONS.yml")
      end

      described_class.run

      expected_content = <<~HEREDOC
        ---
        en:
          level_1:
            sub_level1: Initial content
          test:
            key: Copy en
      HEREDOC

      expect(en_local_file_content).to eq(expected_content)
    end
  end

  describe "modifying existing translations" do
    let(:translation_from_user) do
      <<~HEREDOC
        key: level_1.sub_level1
        en: Updated content en
        fr: Updated content fr
      HEREDOC
    end

    it "adds a new translation key" do
      allow_any_instance_of(Object).to receive(:system) do |_, command|
        File.write("/tmp/TRANSLATIONS.yml", translation_from_user) if command.include?("/tmp/TRANSLATIONS.yml")
      end

      described_class.run

      expected_content = <<~HEREDOC
        ---
        en:
          level_1:
            sub_level1: Updated content en
      HEREDOC

      expect(en_local_file_content).to eq(expected_content)
    end
  end
end
